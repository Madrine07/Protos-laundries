// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import 'order_invoice_id.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const Color purple      = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);

  late Map<String, dynamic> _order;
  bool _cancelling    = false;
  bool _rescheduling  = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  // ── Helpers ──
  Color _statusColor(String? s) {
    switch (s) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF059669);
      case 'washing':   return const Color(0xFF3B82F6);
      case 'delivered': return purple;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s) {
      case 'pending':   return Icons.hourglass_empty_rounded;
      case 'confirmed': return Icons.check_circle_rounded;
      case 'washing':   return Icons.local_laundry_service_rounded;
      case 'delivered': return Icons.delivery_dining_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default:          return Icons.info_rounded;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'pending':   return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'washing':   return 'Washing';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default:          return s ?? 'Unknown';
    }
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  // ── How many days until pickup ──
  int _daysUntilPickup() {
    try {
      final pickup = DateTime.parse(_order['pickup_date']);
      final today  = DateTime.now();
      final diff   = pickup.difference(
          DateTime(today.year, today.month, today.day));
      return diff.inDays;
    } catch (_) {
      return 999;
    }
  }

  bool get _canModify {
    final status = _order['status'] as String?;
    return (status == 'pending' || status == 'confirmed') &&
        _daysUntilPickup() > 1;
  }

  bool get _mustCallBranch {
    final status = _order['status'] as String?;
    return (status == 'pending' || status == 'confirmed') &&
        _daysUntilPickup() <= 1;
  }

  Future<void> _callBranch() async {
    final phone = _order['branch']?['phone'] as String?;
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Cancel ──
  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Order',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to cancel this order? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await _apiService.cancelOrder(_order['id'] as int);
      setState(() => _order['status'] = 'cancelled');
      _snack('Order cancelled successfully');
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  // ── Reschedule ──
  Future<void> _rescheduleOrder() async {
    DateTime? newDate;
    TimeOfDay? newTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Reschedule Pickup',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text('Select a new date and time for your pickup',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 20),

              // Date picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(
                        const Duration(days: 2)),
                    firstDate: DateTime.now().add(
                        const Duration(days: 2)),
                    lastDate: DateTime.now().add(
                        const Duration(days: 30)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: purple),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setSheetState(() => newDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: newDate != null ? lightPurple : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: newDate != null ? purple : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: purple, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        newDate == null
                            ? 'Select new date'
                            : DateFormat('dd MMM yyyy').format(newDate!),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: newDate != null
                              ? purple
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Time picker
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: purple),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setSheetState(() => newTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: newTime != null ? lightPurple : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: newTime != null ? purple : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: purple, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        newTime == null
                            ? 'Select new time'
                            : newTime!.format(ctx),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: newTime != null
                              ? purple
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (newDate == null || newTime == null)
                      ? null
                      : () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirm Reschedule',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (newDate == null || newTime == null) return;

    setState(() => _rescheduling = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(newDate!);
      final formattedTime =
          '${newTime!.hour.toString().padLeft(2, '0')}:${newTime!.minute.toString().padLeft(2, '0')}:00';

      await _apiService.rescheduleOrder(
        orderId:    _order['id'] as int,
        pickupDate: formattedDate,
        pickupTime: formattedTime,
      );

      setState(() {
        _order['pickup_date'] = formattedDate;
        _order['pickup_time'] = formattedTime;
      });

      _snack('Pickup rescheduled successfully ✓');
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _rescheduling = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final status       = _order['status'] as String?;
    final branch       = _order['branch']?['name'] ?? 'Branch';
    final branchPhone  = _order['branch']?['phone'] as String?;
    final finalAmount  = _order['final_amount'] != null
        ? num.tryParse(_order['final_amount'].toString())
        : null;
    final actualKg     = _order['actual_kg'] != null
        ? num.tryParse(_order['actual_kg'].toString())
        : null;
    final paymentStatus = _order['payment_status'] as String?;
    final days         = _daysUntilPickup();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: purple, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order #${_order['id']}',
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEDE9F6)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
        children: [

          // ── Status card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor(status),
                  _statusColor(status).withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _statusColor(status).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_statusIcon(status),
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        branch,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == 'pending' || status == 'confirmed')
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      days <= 0
                          ? 'Today!'
                          : days == 1
                              ? 'Tomorrow'
                              : '$days days away',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Order details ──
          _sectionCard('Order Details', [
            _detailRow(Icons.tag_rounded, 'Order ID',
                '#${_order['id']}'),
            _detailRow(Icons.store_rounded, 'Branch', branch),
            _detailRow(Icons.calendar_today_rounded, 'Pickup Date',
                _order['pickup_date'] ?? '—'),
            _detailRow(Icons.access_time_rounded, 'Pickup Time',
                _order['pickup_time'] ?? '—'),
            _detailRow(Icons.location_on_rounded, 'Pickup Address',
                _order['pickup_address'] ?? '—'),
            if ((_order['instructions'] ?? '').isNotEmpty)
              _detailRow(Icons.notes_rounded, 'Instructions',
                  _order['instructions']),
          ]),

          const SizedBox(height: 14),

          // ── Weight & Amount ──
          _sectionCard('Weight & Payment', [
            _detailRow(Icons.scale_rounded, 'Actual Weight',
                actualKg != null ? '${actualKg}kg' : 'Not weighed yet'),
            _detailRow(Icons.payments_rounded, 'Final Amount',
                finalAmount != null
                    ? 'UGX ${_fmt(finalAmount.toInt())}'
                    : 'Pending weighing'),
            _detailRow(Icons.receipt_rounded, 'Payment Status',
                paymentStatus ?? 'Not paid',
                valueColor: paymentStatus == 'verified'
                    ? const Color(0xFF059669)
                    : paymentStatus == 'pending'
                        ? const Color(0xFFF59E0B)
                        : Colors.grey),
          ]),

          const SizedBox(height: 14),

          // ── Pay button if applicable ──
          if (actualKg != null && paymentStatus == null) ...[
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OrderInvoiceFromId(orderId: _order['id']),
                ),
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('View Invoice & Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── Cancel / Reschedule ──
          if (_canModify) ...[
            _sectionLabel('Manage Order'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _rescheduling ? null : _rescheduleOrder,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFD8B4FE)),
                      ),
                      child: _rescheduling
                          ? const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: purple),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_calendar_rounded,
                                    color: purple, size: 16),
                                SizedBox(width: 6),
                                Text('Reschedule',
                                    style: TextStyle(
                                      color: purple,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _cancelling ? null : _cancelOrder,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFECACA)),
                      ),
                      child: _cancelling
                          ? const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_rounded,
                                    color: Colors.red, size: 16),
                                SizedBox(width: 6),
                                Text('Cancel Order',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // ── Must call branch ──
          if (_mustCallBranch && branchPhone != null) ...[
            _sectionLabel('Need to make changes?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFFD97706), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your pickup is tomorrow or today — changes must be made by calling the branch directly.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _callBranch,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Call Branch Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.3,
              )),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: purple, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    )),
                const SizedBox(height: 2),
                Text(value ?? '—',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? const Color(0xFF1A1A2E),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            )),
      ],
    );
  }
}