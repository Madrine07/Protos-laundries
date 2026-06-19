// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_null_in_if_null_operators

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_badge.dart';

class TrackOrderScreen extends StatefulWidget {
  final int? orderId;
  const TrackOrderScreen({super.key, this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  static const Color purple      = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color gold        = Color(0xFFD4AF37);
  static const Color bgColor     = Color(0xFFF8F7FF);
  static const Color surfaceLow  = Color(0xFFF8F1FA);
  static const Color onSurface   = Color(0xFF1D1A20);
  static const Color textGrey    = Color(0xFF7B7482);
  static const Color outline     = Color(0xFFCCC3D2);
  static const Color successGreen = Color(0xFF10B981);

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;

  static const List<_Stage> _stages = [
    _Stage(key: 'picked_up',        label: 'Picked Up',        subtitle: 'Your laundry has been collected',  icon: Icons.local_shipping_rounded),
    _Stage(key: 'washing',          label: 'Washing',          subtitle: 'Your clothes are being cleaned',   icon: Icons.local_laundry_service_rounded),
    _Stage(key: 'out_for_delivery', label: 'Out for Delivery', subtitle: 'On the way back to you',           icon: Icons.delivery_dining_rounded),
    _Stage(key: 'delivered',        label: 'Delivered',        subtitle: 'Enjoy your fresh laundry!',        icon: Icons.check_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    NotificationBadge.refresh();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchOrder() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');
      final Uri url = widget.orderId != null
          ? Uri.parse('https://protos.dina-apartments.com/api/orders/${widget.orderId}')
          : Uri.parse('https://protos.dina-apartments.com/api/orders');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        if (widget.orderId != null) {
          setState(() => _order = data['order']);
        } else {
          final orders = (data['orders'] as List?) ?? [];
          final active = orders.firstWhere(
            (o) => o['status'] != 'delivered' && o['status'] != 'cancelled',
            orElse: () => orders.isNotEmpty ? orders.first : null,
          );
          setState(() => _order = active);
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to load order');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _currentStageIndex(String? status) {
    switch (status) {
      case 'picked_up':        return 0;
      case 'washing':          return 1;
      case 'out_for_delivery': return 2;
      case 'delivered':        return 3;
      default:                 return -1;
    }
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _fmtDate(String? s) {
    if (s == null) return '—';
    final d = DateTime.tryParse(s);
    if (d == null) return s;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}, ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(children: [
          Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 24),
          Container(height: 280, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 24),
          Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          const SizedBox(height: 24),
          Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
        ]),
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
          unselectedItemColor: textGrey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            if (index == 0) Navigator.pushNamed(context, '/home');
            if (index == 1) Navigator.pushNamed(context, '/orders');
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
              icon: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.notifications_rounded),
                if (unreadCount > 0)
                  Positioned(right: -6, top: -4, child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
                    child: Text(unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E)),
                        textAlign: TextAlign.center),
                  )),
              ]),
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: _loading
            ? _buildShimmer()
            : _error != null
                ? _buildError()
                : _order == null
                    ? _buildNoOrder()
                    : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline_rounded, size: 56, color: gold.withOpacity(0.5)),
      const SizedBox(height: 14),
      Text(_error!, style: const TextStyle(fontSize: 13, color: textGrey), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(onTap: _fetchOrder, child: Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(14)), child: const Text('Try Again', style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800)))),
    ])));
  }

  Widget _buildNoOrder() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.local_laundry_service_rounded, size: 72, color: textGrey.withOpacity(0.2)),
      const SizedBox(height: 16),
      const Text('No active order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: onSurface)),
      const SizedBox(height: 8),
      const Text('Schedule a pickup to get started', style: TextStyle(fontSize: 13, color: textGrey)),
      const SizedBox(height: 24),
      GestureDetector(onTap: () => Navigator.pushNamed(context, '/schedule'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(16)), child: const Text('Schedule Pickup', style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800, fontSize: 15)))),
    ])));
  }

  Widget _buildContent() {
    final order      = _order!;
    final status     = order['status'] as String?;
    final stageIndex = _currentStageIndex(status);
    final isDelivered = status == 'delivered';
    return RefreshIndicator(
      onRefresh: _fetchOrder, color: gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(order, stageIndex, isDelivered),
          const SizedBox(height: 24),
          _buildTracker(stageIndex, order),
          const SizedBox(height: 24),
          _buildOrderDetails(order),
          const SizedBox(height: 24),
          _buildContactCard(order),
        ]),
      ),
    );
  }

  Widget _buildHeader(Map order, int stageIndex, bool isDelivered) {
    final statusLabel = stageIndex >= 0 ? _stages[stageIndex].label : 'Pending Pickup';
    final Color statusColor;
    final Color statusBg;
    if (isDelivered) { statusColor = successGreen; statusBg = const Color(0xFFD1FAE5); }
    else if (stageIndex >= 0) { statusColor = purple; statusBg = lightPurple; }
    else { statusColor = textGrey; statusBg = surfaceLow; }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(24), border: Border.all(color: outline.withOpacity(0.35))),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        Positioned(right: -6, top: 0, bottom: 0, child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _headerBar(height: 44, color: purple.withOpacity(0.15)),
          const SizedBox(width: 5),
          _headerBar(height: 26, color: gold.withOpacity(0.30), marginTop: 12),
          const SizedBox(width: 5),
          _headerBar(height: 56, color: purple.withOpacity(0.10)),
          const SizedBox(width: 5),
          _headerBar(height: 20, color: gold.withOpacity(0.22), marginTop: 20),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('TRACK ORDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textGrey)),
          ]),
          const SizedBox(height: 10),
          Text('Order #${order['id'] ?? '—'}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: onSurface, height: 1.15)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _headerBar({required double height, required Color color, double marginTop = 0}) {
    return Container(width: 8, height: height, margin: EdgeInsets.only(top: marginTop), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
  }

  Widget _buildTracker(int currentIndex, Map order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: outline.withOpacity(0.5)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          const Text('Live Journey', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: onSurface)),
        ]),
        const SizedBox(height: 24),
        ...List.generate(_stages.length, (i) {
          final isDone    = i < currentIndex;
          final isActive  = i == currentIndex;
          final isPending = i > currentIndex;
          final isLast    = i == _stages.length - 1;
          return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 40, child: Column(children: [
              _stageCircle(isDone: isDone, isActive: isActive, isPending: isPending, stage: _stages[i]),
              if (!isLast) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: isDone ? purple : outline.withOpacity(0.4), borderRadius: BorderRadius.circular(1)))),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28, top: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_stages[i].label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDone ? onSurface : isActive ? purple : textGrey)),
                const SizedBox(height: 2),
                Text(isActive ? _stages[i].subtitle : isDone ? 'Completed' : 'Waiting...', style: TextStyle(fontSize: 12, color: isActive ? purple.withOpacity(0.7) : textGrey, fontWeight: isActive ? FontWeight.w500 : FontWeight.w400)),
                if ((isDone || isActive) && _getStageTime(order, i) != null) ...[
                  const SizedBox(height: 4),
                  Text(_getStageTime(order, i)!, style: TextStyle(fontSize: 11, color: isDone ? textGrey : gold, fontWeight: FontWeight.w500)),
                ],
              ]),
            )),
          ]));
        }),
      ]),
    );
  }

  Widget _stageCircle({required bool isDone, required bool isActive, required bool isPending, required _Stage stage}) {
    if (isDone) return Container(width: 40, height: 40, decoration: const BoxDecoration(color: purple, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 20));
    if (isActive) return Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: purple, width: 3), boxShadow: [BoxShadow(color: purple.withOpacity(0.25), blurRadius: 10, spreadRadius: 2)]), child: Icon(stage.icon, color: purple, size: 18));
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: surfaceLow, shape: BoxShape.circle, border: Border.all(color: outline.withOpacity(0.5))), child: Icon(stage.icon, color: outline, size: 18));
  }

  String? _getStageTime(Map order, int index) {
    final keys = ['picked_up_at', 'washing_started_at', 'out_for_delivery_at', 'delivered_at'];
    if (index >= keys.length) return null;
    final val = order[keys[index]];
    if (val == null) return null;
    return _fmtDate(val.toString());
  }

  Widget _buildOrderDetails(Map order) {
    final items        = order['items'] as List? ?? [];
    final branch       = order['branch'] is Map ? order['branch'] as Map : null;
    final estimatedMin = order['estimated_min'];
    final estimatedMax = order['estimated_max'];
    final totalAmount  = order['total_amount'];
    final basketSize   = order['basket_size'] as String?;
    final instructions = order['instructions'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: outline.withOpacity(0.5)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          const Text('Order Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: onSurface)),
        ]),
        const SizedBox(height: 16),
        if (branch != null) _detailRow(Icons.store_mall_directory_rounded, 'Branch', branch['name'] ?? '—'),
        if ((order['pickup_address'] ?? '').toString().isNotEmpty) _detailRow(Icons.location_on_rounded, 'Address', order['pickup_address']),
        if (order['pickup_date'] != null) _detailRow(Icons.calendar_today_rounded, 'Pickup Date', '${order['pickup_date']}${order['pickup_time'] != null ? '  ${order['pickup_time']}' : ''}'),
        if (basketSize != null) _detailRow(Icons.shopping_basket_rounded, 'Basket Size', _capitalise(basketSize)),
        const SizedBox(height: 12),
        if (items.isNotEmpty) ...[
          const Text('Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textGrey, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          ...items.map((item) {
            final name = item['item'] ?? item['name'] ?? '?';
            final qty  = item['quantity'] ?? 1;
            return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 10, top: 1), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2))),
              Expanded(child: Text(_capitalise(name.toString()), style: const TextStyle(fontSize: 13, color: onSurface))),
              Text('× $qty', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textGrey)),
            ]));
          }),
          const SizedBox(height: 12),
        ],
        if (instructions != null && instructions.isNotEmpty) ...[
          Container(width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: outline.withOpacity(0.4))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.notes_rounded, size: 14, color: textGrey), const SizedBox(width: 8),
              Expanded(child: Text(instructions, style: const TextStyle(fontSize: 12, color: textGrey, height: 1.5))),
            ])),
          const SizedBox(height: 12),
        ],
        Divider(color: outline.withOpacity(0.4)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textGrey)),
          Text(
            totalAmount != null ? 'UGX ${_fmt(int.tryParse(totalAmount.toString()) ?? 0)}' : (estimatedMin != null && estimatedMax != null) ? 'UGX ${_fmt(estimatedMin)} – ${_fmt(estimatedMax)}' : '—',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: purple),
          ),
        ]),
        if (totalAmount == null && estimatedMin != null) const Padding(padding: EdgeInsets.only(top: 4), child: Text('Final amount confirmed after weighing', style: TextStyle(fontSize: 11, color: textGrey))),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: purple)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: textGrey, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, color: onSurface, fontWeight: FontWeight.w500)),
      ])),
    ]));
  }

  Widget _buildContactCard(Map order) {
    final driver = order['driver'] is Map ? order['driver'] as Map : null;
    final branch = order['branch'] is Map ? order['branch'] as Map : null;
    final phone  = driver?['phone'] ?? branch?['phone'] ?? null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: gold.withOpacity(0.07), borderRadius: BorderRadius.circular(24), border: Border.all(color: gold.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: gold.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.support_agent_rounded, color: gold, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(driver != null ? (driver['name'] ?? 'Your Driver') : 'Protos Support', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: onSurface)),
          Text(driver != null ? 'Your driver' : 'Branch contact', style: const TextStyle(fontSize: 12, color: textGrey)),
        ])),
        if (phone != null) GestureDetector(
          onTap: () {},
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.call_rounded, size: 16, color: Color(0xFF1A0A2E)), SizedBox(width: 6),
              Text('Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A0A2E))),
            ])),
        ),
      ]),
    );
  }

  String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }
}

class _Stage {
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;
  const _Stage({required this.key, required this.label, required this.subtitle, required this.icon});
}