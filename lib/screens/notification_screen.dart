// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
  static const Color purple = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFFF3E8FF);

  List<dynamic> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/notifications'),
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
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('http://127.0.0.1:8000/api/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Update locally
      if (!mounted) return;
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['read_at'] = DateTime.now().toIso8601String();
        }
      });
    } catch (e) {
      // silent fail
    }
  }

  Future<void> _markAllAsRead() async {
    for (final n in _notifications) {
      if (n['read_at'] == null) {
        await _markAsRead(n['id']);
      }
    }
  }

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

  Color _getColor(String? type) {
    switch (type) {
      case 'order_update': return purple;
      case 'payment':      return const Color(0xFF059669);
      case 'promo':        return const Color(0xFFD97706);
      default:             return Colors.grey;
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

    if (notification['read_at'] == null) {
      _markAsRead(notification['id']);
    }

    // Always go to orders screen — let the order card handle payment
    if (type == 'order_update' && data['order_id'] != null) {
      Navigator.pushNamed(context, '/orders');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/orders');
          if (index == 2) Navigator.pushNamed(context, '/schedule');
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
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          'Your order updates and promotions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unread badge + mark all read
                  if (_unreadCount > 0)
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all_rounded,
                          size: 16, color: purple),
                      label: const Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 11,
                          color: purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _fetchNotifications,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.refresh_rounded, color: purple),
                        if (_unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Unread count banner
            if (_unreadCount > 0 && !_loading)
              Container(
                margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 8, color: purple),
                    const SizedBox(width: 8),
                    Text(
                      '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: purple,
                      ),
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
                                  style:
                                      const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchNotifications,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: purple),
                                child: const Text('Retry',
                                    style:
                                        TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_rounded,
                                    size: 72,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Order updates will appear here',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchNotifications,
                              color: purple,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    18, 4, 18, 20),
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final n = _notifications[index];
                                  final data = n['data'] is Map
                                      ? n['data'] as Map
                                      : <String, dynamic>{};
                                  final type = n['type'] as String?;
                                  final isRead = n['read_at'] != null;

                                  return GestureDetector(
                                    onTap: () => _onTapNotification(n),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isRead
                                            ? Colors.white
                                            : lightPurple,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isRead
                                              ? const Color(0xFFE5E7EB)
                                              : const Color(0xFFDDD6FE),
                                          width: isRead ? 1 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [

                                          // Icon
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _getColor(type)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),
                                            child: Icon(
                                              _getIcon(type),
                                              color: _getColor(type),
                                              size: 20,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        data['title'] ??
                                                            'Notification',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              isRead
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w800,
                                                          color: const Color(
                                                              0xFF1A1A2E),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: 8),
                                                    Text(
                                                      _timeAgo(n[
                                                          'created_at']),
                                                      style:
                                                          const TextStyle(
                                                        fontSize: 10,
                                                        color: Color(
                                                            0xFF9CA3AF),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  data['body'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isRead
                                                        ? const Color(
                                                            0xFF6B7280)
                                                        : const Color(
                                                            0xFF374151),
                                                  ),
                                                ),

                                                // Tap hint for order updates
                                                if (type ==
                                                        'order_update' &&
                                                    data['order_id'] !=
                                                        null) ...[
                                                  const SizedBox(
                                                      height: 8),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    10,
                                                                vertical:
                                                                    4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: purple
                                                              .withOpacity(
                                                                  0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8),
                                                        ),
                                                        child: const Text(
                                                          'View Order →',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                            color: purple,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          // Unread dot
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets
                                                  .only(top: 4, left: 6),
                                              decoration:
                                                  const BoxDecoration(
                                                color: purple,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
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
}