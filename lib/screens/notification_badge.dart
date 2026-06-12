import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationBadge {
  static final ValueNotifier<int> count = ValueNotifier(0);

  static Future<void> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        count.value = data['count'] ?? 0;
      }
    } catch (_) {
      // silent fail
    }
  }

  static void decrement() {
    if (count.value > 0) count.value--;
  }

  static void clear() {
    count.value = 0;
  }
}