// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ── Theme ──────────────────────────────────────────────────────
  static const Color purple     = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);
  static const Color gold       = Color(0xFFD4AF37);
  static const Color bgColor    = Color(0xFFF8F7FF);
  static const Color surfaceLow = Color(0xFFF8F1FA);
  static const Color onSurface  = Color(0xFF1D1A20);
  static const Color textGrey   = Color(0xFF7B7482);
  static const Color outline    = Color(0xFFCCC3D2);

  // ── Tab state ──────────────────────────────────────────────────
  int _activeTab = 0; // 0 = Laundry, 1 = Promotions

  // ── Notifications (laundry) ────────────────────────────────────
  List<dynamic> _notifications = [];
  bool _loadingNotifs = true;
  String? _notifsError;

  // ── Promotions ─────────────────────────────────────────────────
  List<dynamic> _promotions = [];
  bool _loadingPromos = true;
  String? _promosError;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _fetchPromotions();
  }

  // ── Auth token ─────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ── Fetch notifications ────────────────────────────────────────
  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() { _loadingNotifs = true; _notifsError = null; });
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('https://protos.dina-apartments.com/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _notifications = data['notifications'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to load');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _notifsError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingNotifs = false);
    }
  }

  // ── Fetch promotions ───────────────────────────────────────────
  Future<void> _fetchPromotions() async {
    if (!mounted) return;
    setState(() { _loadingPromos = true; _promosError = null; });
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('https://protos.dina-apartments.com/api/promotions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _promotions = data['promotions'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to load promotions');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _promosError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingPromos = false);
    }
  }

  // ── Mark single as read ────────────────────────────────────────
  Future<void> _markAsRead(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('https://protos.dina-apartments.com/api/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read_at'] = DateTime.now().toIso8601String();
        }
      });
    } catch (_) {
      // silent fail
    }
  }

  // ── Mark all as read ───────────────────────────────────────────
  Future<void> _markAllAsRead() async {
    for (final n in _notifications) {
      if (n['read_at'] == null) await _markAsRead(n['id']);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  int get _unreadCount =>
      _notifications.where((n) => n['read_at'] == null).length;

  IconData _getIcon(String? type) {
    switch (type) {
      case 'order_update': return Icons.local_laundry_service_rounded;
      case 'payment':      return Icons.payments_rounded;
      case 'promo':        return Icons.local_offer_rounded;
      default:             return Icons.notifications_rounded;
    }
  }

  Color _getNotifColor(String? type) {
    switch (type) {
      case 'order_update': return purple;
      case 'payment':      return const Color(0xFF059669);
      case 'promo':        return gold;
      default:             return textGrey;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _onTapNotification(Map notification) {
    final type = notification['type'] as String?;
    final data = notification['data'] is Map
        ? notification['data'] as Map
        : <String, dynamic>{};

    if (notification['read_at'] == null) _markAsRead(notification['id']);

    if (type == 'order_update' && data['order_id'] != null) {
      Navigator.pushNamed(context, '/orders');
    }
  }

  // ── Promo status helpers ───────────────────────────────────────
  bool _isPromoActive(Map promo) {
    final now = DateTime.now();
    final start = DateTime.tryParse(promo['start_date'] ?? '');
    final end   = DateTime.tryParse(promo['end_date'] ?? '');
    if (start == null || end == null) return false;
    return now.isAfter(start) && now.isBefore(end);
  }

  bool _isPromoUpcoming(Map promo) {
    final now   = DateTime.now();
    final start = DateTime.tryParse(promo['start_date'] ?? '');
    return start != null && now.isBefore(start);
  }

  String _promoDateRange(Map promo) {
    String fmt(String? s) {
      if (s == null) return '?';
      final d = DateTime.tryParse(s);
      if (d == null) return '?';
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }
    return '${fmt(promo['start_date'])} – ${fmt(promo['end_date'])}';
  }

  // ════════════════════════════════════════════════════════════════
  //  UI BUILDERS
  // ════════════════════════════════════════════════════════════════

  // ── Pill tab toggle ────────────────────────────────────────────
  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabPill(index: 0, label: 'Laundry', icon: Icons.local_laundry_service_rounded,
              badge: _unreadCount > 0 ? '$_unreadCount' : null),
          _tabPill(index: 1, label: 'Promotions', icon: Icons.local_offer_rounded,
              badge: _promotions.where((p) => _isPromoActive(p)).isNotEmpty ? null : null),
        ],
      ),
    );
  }

  Widget _tabPill({
    required int index,
    required String label,
    required IconData icon,
    String? badge,
  }) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
            border: isActive ? Border.all(color: outline.withOpacity(0.4)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? gold : textGrey),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isActive ? onSurface : textGrey,
                  )),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 3, height: 14,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2)),
                  ),
                  const Text('Notifications',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: onSurface)),
                ]),
                const SizedBox(height: 2),
                const Text('Updates and offers, all in one place',
                    style: TextStyle(fontSize: 12, color: textGrey)),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: () {
              _fetchNotifications();
              _fetchPromotions();
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outline.withOpacity(0.5)),
              ),
              child: const Icon(Icons.refresh_rounded, color: gold, size: 18),
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gold.withOpacity(0.35)),
                ),
                child: const Text('Mark all read',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8B6914), fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Notification card ──────────────────────────────────────────
  Widget _buildNotifCard(Map notification) {
    final data  = notification['data'] is Map ? notification['data'] as Map : <String, dynamic>{};
    final type  = notification['type'] as String?;
    final isRead = notification['read_at'] != null;
    final color = _getNotifColor(type);

    return GestureDetector(
      onTap: () => _onTapNotification(notification),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? outline.withOpacity(0.5) : gold.withOpacity(0.35),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Notification',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            color: onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_timeAgo(notification['created_at']),
                          style: const TextStyle(fontSize: 10, color: textGrey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['body'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead ? textGrey : const Color(0xFF374151),
                    ),
                  ),
                  if (type == 'order_update' && data['order_id'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('View Order →',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B6914))),
                    ),
                  ],
                ],
              ),
            ),
            // Unread dot
            if (!isRead)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4, left: 6),
                decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  // ── Promo card ─────────────────────────────────────────────────
  Widget _buildPromoCard(Map promo) {
    final isActive   = _isPromoActive(promo);
    final isUpcoming = _isPromoUpcoming(promo);

    // Status label + color
    final String statusLabel;
    final Color  statusColor;
    final Color  statusBg;
    if (isActive) {
      statusLabel = 'ACTIVE';
      statusColor = const Color(0xFF166534);
      statusBg    = const Color(0xFFDCFCE7);
    } else if (isUpcoming) {
      statusLabel = 'UPCOMING';
      statusColor = const Color(0xFF92400E);
      statusBg    = const Color(0xFFFEF3C7);
    } else {
      statusLabel = 'EXPIRED';
      statusColor = textGrey;
      statusBg    = surfaceLow;
    }

    final discountValue = promo['discount_value'];
    final discountType  = promo['discount_type'] as String?;
    final discountText  = discountValue != null
        ? discountType == 'percentage'
            ? '${discountValue.toString()}% OFF'
            : 'UGX ${discountValue.toString()} OFF'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? gold.withOpacity(0.5) : outline.withOpacity(0.5),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? gold.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top band
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: isActive ? gold.withOpacity(0.07) : surfaceLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Gold offer icon
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? gold.withOpacity(0.15) : outline.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer_rounded,
                      color: isActive ? gold : textGrey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo['title'] ?? 'Promotion',
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: onSurface,
                        ),
                      ),
                      if (discountText != null) ...[
                        const SizedBox(height: 2),
                        Text(discountText,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: isActive ? gold : textGrey,
                            )),
                      ],
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: statusColor, letterSpacing: 0.5,
                      )),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((promo['description'] ?? '').isNotEmpty) ...[
                  Text(
                    promo['description'],
                    style: const TextStyle(fontSize: 13, color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                ],
                // Date range row
                Row(children: [
                  Container(
                    width: 3, height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? gold : outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_rounded, size: 13, color: textGrey),
                  const SizedBox(width: 4),
                  Text(
                    _promoDateRange(promo),
                    style: const TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500),
                  ),
                ]),
                // Promo code if available
                if ((promo['code'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? gold.withOpacity(0.1) : surfaceLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? gold.withOpacity(0.4) : outline.withOpacity(0.4),
                        ),
                      ),
                      child: Row(children: [
                        const Icon(Icons.confirmation_number_rounded, size: 13, color: textGrey),
                        const SizedBox(width: 6),
                        Text('Code: ',
                            style: const TextStyle(fontSize: 12, color: textGrey)),
                        Text(promo['code'],
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: isActive ? gold : textGrey,
                              letterSpacing: 0.5,
                            )),
                      ]),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Laundry tab content ────────────────────────────────────────
  Widget _buildLaundryTab() {
    if (_loadingNotifs) {
      return const Center(child: CircularProgressIndicator(color: gold));
    }
    if (_notifsError != null) {
      return _buildError(_notifsError!, _fetchNotifications, color: gold);
    }
    if (_notifications.isEmpty) {
      return _buildEmpty(
        icon: Icons.notifications_off_rounded,
        title: 'No notifications yet',
        subtitle: 'Order updates will appear here',
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      color: gold,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return _buildNotifCard(n is Map ? n : {});
        },
      ),
    );
  }

  // ── Promotions tab content ─────────────────────────────────────
  Widget _buildPromosTab() {
    if (_loadingPromos) {
      return const Center(child: CircularProgressIndicator(color: gold));
    }
    if (_promosError != null) {
      return _buildError(_promosError!, _fetchPromotions, color: gold);
    }
    if (_promotions.isEmpty) {
      return _buildEmpty(
        icon: Icons.local_offer_rounded,
        title: 'No promotions right now',
        subtitle: "We'll let you know when there's a deal",
        iconColor: gold,
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchPromotions,
      color: gold,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          final p = _promotions[index];
          return _buildPromoCard(p is Map ? p : {});
        },
      ),
    );
  }

  // ── Shared: empty state ────────────────────────────────────────
  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: (iconColor ?? textGrey).withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textGrey)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: textGrey)),
        ],
      ),
    );
  }

  // ── Shared: error state ────────────────────────────────────────
  Widget _buildError(String error, VoidCallback retry, {Color color = purple}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: color.withOpacity(0.5), size: 52),
            const SizedBox(height: 12),
            Text(error,
                style: const TextStyle(fontSize: 13, color: textGrey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: retry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
          if (index == 4) Navigator.pushNamed(context, '/account');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildTabToggle(),
            // Tab content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation, child: child,
                ),
                child: _activeTab == 0
                    ? KeyedSubtree(key: const ValueKey(0), child: _buildLaundryTab())
                    : KeyedSubtree(key: const ValueKey(1), child: _buildPromosTab()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}