// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_field, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_badge.dart';
import 'payment_screen.dart';
import 'order_invoice_id.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color purple      = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color gold        = Color(0xFFD4AF37);

  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    NotificationBadge.refresh();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('https://protos.dina-apartments.com/api/my-orders'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
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
      case 'pending':          return const Color(0xFFF59E0B);
      case 'confirmed':        return const Color(0xFF059669);
      case 'picked_up':        return const Color(0xFF3B82F6);
      case 'washing':          return purple;
      case 'out_for_delivery': return const Color(0xFFF59E0B);
      case 'delivered':        return const Color(0xFF059669);
      case 'cancelled':        return Colors.red;
      default:                 return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending':          return 'Pending';
      case 'confirmed':        return 'Confirmed';
      case 'picked_up':        return 'Picked Up';
      case 'washing':          return 'Washing';
      case 'out_for_delivery': return 'Out for Delivery';
      case 'delivered':        return 'Delivered';
      case 'cancelled':        return 'Cancelled';
      default:                 return status ?? 'Unknown';
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'pending':          return Icons.hourglass_empty_rounded;
      case 'confirmed':        return Icons.check_circle_rounded;
      case 'picked_up':        return Icons.local_shipping_rounded;
      case 'washing':          return Icons.local_laundry_service_rounded;
      case 'out_for_delivery': return Icons.delivery_dining_rounded;
      case 'delivered':        return Icons.check_circle_rounded;
      case 'cancelled':        return Icons.cancel_rounded;
      default:                 return Icons.info_rounded;
    }
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 140,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  // ── Bottom nav with badge ──────────────────────────────────────
  Widget _buildBottomNav() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationBadge.count,
      builder: (context, unreadCount, _) {
        return BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: purple,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/home');
            if (index == 2) Navigator.pushNamed(context, '/schedule');
            if (index == 3) Navigator.pushNamed(context, '/notifications');
            if (index == 4) Navigator.pushNamed(context, '/account');
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
            BottomNavigationBarItem(
              label: 'Notifications',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded),
                  if (unreadCount > 0)
                    Positioned(
                      right: -6, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        );
      },
    );
  }

  Widget _bottomSection(Map order) {
    final actualKg      = num.tryParse(order['actual_kg']?.toString() ?? '');
    final paymentStatus = order['payment_status'] as String?;
    final paymentMethod = order['payment_method'] as String?;
    final hasWeight     = actualKg != null;
    final hasPaid       = paymentStatus != null;
    final isVerified    = paymentStatus == 'verified';

    if (isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 16),
          SizedBox(width: 6),
          Text('Payment Verified ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
        ]),
      );
    }

    if (hasPaid && !isVerified) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBEB),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 6),
          Text(
            paymentMethod == 'cash' ? 'Cash on Delivery Selected' : 'Payment Submitted — Awaiting Verification',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
          ),
        ]),
      );
    }

    if (hasWeight && !hasPaid) {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderInvoiceFromId(orderId: order['id']))),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.payment_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('View Invoice & Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8FF),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
      ),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.hourglass_empty_rounded, color: Color(0xFF9CA3AF), size: 14),
        SizedBox(width: 6),
        Text('Waiting for laundry to be weighed...', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: _buildBottomNav(),
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
                        Text('My Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                        Text('Track and pay for your laundry', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchOrders,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F1FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCCC3D2).withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: gold, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT ──
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.error_outline_rounded, color: gold.withOpacity(0.5), size: 52),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _fetchOrders,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(14)),
                                  child: const Text('Try Again', style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ]),
                          ),
                        )
                      : _orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_laundry_service_rounded, size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF))),
                                  const SizedBox(height: 8),
                                  const Text('Schedule your first pickup\nand we\'ll handle the rest!',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)), textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/schedule'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(color: purple, borderRadius: BorderRadius.circular(14)),
                                      child: const Text('Schedule Pickup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchOrders,
                              color: gold,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                                itemCount: _orders.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final order         = _orders[index];
                                  final status        = order['status'] as String?;
                                  final branch        = order['branch']?['name'] ?? 'Branch';
                                  final finalAmount   = order['final_amount'] != null ? num.tryParse(order['final_amount'].toString()) : null;
                                  final actualKg      = order['actual_kg'] != null ? num.tryParse(order['actual_kg'].toString()) : null;
                                  final paymentStatus = order['payment_status'] as String?;
                                  final hasPaid       = paymentStatus != null;

                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(order: Map<String, dynamic>.from(order)),
                                    )),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: hasPaid ? const Color(0xFF6EE7B7) : actualKg != null ? const Color(0xFFDDD6FE) : const Color(0xFFE5E7EB),
                                          width: hasPaid || actualKg != null ? 1.5 : 1,
                                        ),
                                        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 42, height: 42,
                                                      decoration: BoxDecoration(
                                                        color: _statusColor(status).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(_statusIcon(status), color: _statusColor(status), size: 20),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                        Text('Order #${order['id']}',
                                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                                        Text(branch, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                                      ]),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: _statusColor(status).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(_statusLabel(status),
                                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(status))),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Container(height: 1, color: const Color(0xFFF3F4F6)),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    _detailChip(Icons.scale_rounded,
                                                        actualKg != null ? '${actualKg}kg' : 'Not weighed',
                                                        actualKg != null ? purple : Colors.grey),
                                                    const SizedBox(width: 8),
                                                    _detailChip(Icons.payments_rounded,
                                                        finalAmount != null ? 'UGX ${_fmt(finalAmount.toInt())}' : 'Pending',
                                                        finalAmount != null ? const Color(0xFF059669) : Colors.grey),
                                                    const SizedBox(width: 8),
                                                    _detailChip(Icons.calendar_today_rounded,
                                                        order['pickup_date'] ?? 'Walk-in', Colors.grey),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
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
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(child: Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}