// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_field, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_screen.dart';
import 'order_invoice_id.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);

  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/my-orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _orders = data['orders'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF059669);
      case 'washing':   return const Color(0xFF3B82F6);
      case 'delivered': return purple;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending':   return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'washing':   return 'Washing';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default:          return status ?? 'Unknown';
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'pending':   return Icons.hourglass_empty_rounded;
      case 'confirmed': return Icons.check_circle_rounded;
      case 'washing':   return Icons.local_laundry_service_rounded;
      case 'delivered': return Icons.delivery_dining_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default:          return Icons.info_rounded;
    }
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  Widget _bottomSection(Map order) {
    final actualKg = num.tryParse(order['actual_kg']?.toString() ?? '');
    final finalAmount = num.tryParse(order['final_amount']?.toString() ?? '');
    final paymentStatus = order['payment_status'] as String?;
    final paymentMethod = order['payment_method'] as String?;
    final hasWeight = actualKg != null;
    final hasPaid = paymentStatus != null;
    final isVerified = paymentStatus == 'verified';

    // ── Payment verified ──
    if (isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 16),
            SizedBox(width: 6),
            Text(
              'Payment Verified ✓',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }

    // ── Payment submitted, pending verification ──
    if (hasPaid && !isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBEB),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded,
                color: Color(0xFFD97706), size: 16),
            const SizedBox(width: 6),
            Text(
              paymentMethod == 'cash'
                  ? 'Cash on Delivery Selected'
                  : 'Payment Submitted — Awaiting Verification',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      );
    }

    // ── Weighed, ready to pay ──
    if (hasWeight && !hasPaid) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderInvoiceFromId(orderId: order['id']),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'View Invoice & Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Not weighed yet ──
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty_rounded,
              color: Color(0xFF9CA3AF), size: 14),
          SizedBox(width: 6),
          Text(
            'Waiting for laundry to be weighed...',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 2) Navigator.pushNamed(context, '/schedule');
          if (index == 3) Navigator.pushNamed(context, '/notifications');
          if (index == 4) Navigator.pushNamed(context, '/account');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Orders',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            )),
                        Text('Track and pay for your laundry',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _fetchOrders,
                    icon: const Icon(Icons.refresh_rounded, color: purple),
                  ),
                ],
              ),
            ),

            // ── CONTENT ──
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: purple))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchOrders,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: purple),
                                child: const Text('Retry',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_laundry_service_rounded,
                                      size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  const Text('No orders yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF9CA3AF),
                                      )),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Schedule your first pickup\nand we\'ll handle the rest!',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF)),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/schedule'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: purple,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Schedule Pickup',
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchOrders,
                              color: purple,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    18, 8, 18, 20),
                                itemCount: _orders.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  final status = order['status'] as String?;
                                  final branch =
                                      order['branch']?['name'] ?? 'Branch';
                                  final finalAmount =
                                      order['final_amount'] != null
                                          ? num.tryParse(
                                              order['final_amount'].toString())
                                          : null;
                                  final actualKg = order['actual_kg'] != null
                                      ? num.tryParse(
                                          order['actual_kg'].toString())
                                      : null;
                                  final paymentStatus =
                                      order['payment_status'] as String?;
                                  final hasPaid = paymentStatus != null;

                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(
                                          order: Map<String, dynamic>.from(order),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: hasPaid
                                              ? const Color(0xFF6EE7B7)
                                              : actualKg != null
                                                  ? const Color(0xFFDDD6FE)
                                                  : const Color(0xFFE5E7EB),
                                          width: hasPaid || actualKg != null
                                              ? 1.5
                                              : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // ── Order Header ──
                                          Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 42,
                                                      height: 42,
                                                      decoration: BoxDecoration(
                                                        color: _statusColor(
                                                                status)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        _statusIcon(status),
                                                        color: _statusColor(
                                                            status),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Order #${order['id']}',
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Color(
                                                                  0xFF1A1A2E),
                                                            ),
                                                          ),
                                                          Text(branch,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF9CA3AF),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: _statusColor(
                                                                status)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        _statusLabel(status),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: _statusColor(
                                                              status),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Container(
                                                    height: 1,
                                                    color: const Color(
                                                        0xFFF3F4F6)),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    _detailChip(
                                                      Icons.scale_rounded,
                                                      actualKg != null
                                                          ? '${actualKg}kg'
                                                          : 'Not weighed',
                                                      actualKg != null
                                                          ? purple
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _detailChip(
                                                      Icons.payments_rounded,
                                                      finalAmount != null
                                                          ? 'UGX ${_fmt(finalAmount.toInt())}'
                                                          : 'Pending',
                                                      finalAmount != null
                                                          ? const Color(
                                                              0xFF059669)
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _detailChip(
                                                      Icons
                                                          .calendar_today_rounded,
                                                      order['pickup_date'] ??
                                                          'Walk-in',
                                                      Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // ── Bottom Section ──
                                          _bottomSection(order),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}