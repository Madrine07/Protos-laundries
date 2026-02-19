import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  // --- Login method ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      return data;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  // --- Request OTP for registration ---
  Future<void> requestOtp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register/request-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Failed to request OTP");
    }
  }

  // --- Verify OTP and create user ---
  Future<Map<String, dynamic>> verifyOtp({
    required String name,
    required String email,
    required String password,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "otp": otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      return data;
    } else {
      throw Exception(data["message"] ?? "OTP verification failed");
    }
  }

  // --- Resend OTP ---
  Future<void> resendOtp({required String email}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register/resend-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Failed to resend OTP");
    }
  }

  // --- Send OTP for password recovery ---
  Future<void> sendPasswordRecoveryOtp(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/password/request-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"] ?? "Failed to send OTP");
    }
  }

  // Verify OTP
  Future<void> verifyPasswordOtp({
  required String email,
  required String otp,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/password/verify-otp"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Invalid OTP");
  }
}

// Reset passowrd

  Future<void> resetPassword({
  required String email,
  required String otp,
  required String password,
  required String confirmPassword,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/password/reset"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
      "password": password,
      "password_confirmation": confirmPassword,
    }),
  );

  if (response.statusCode != 200) {
    final data = jsonDecode(response.body);
    throw Exception(data["message"] ?? "Password reset failed");
  }
}


Future<Map<String, dynamic>> createOrder({
  required int branchId,
  required String pickupAddress,
  required String pickupDate,
  required String pickupTime,
  String? instructions,
  String? basketSize,
  int estimatedMin = 0,
  int estimatedMax = 0,
  required Map<String, int> items,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
    throw Exception("No authentication token found. Please login.");
  }

  final List<Map<String, dynamic>> itemsList = [];
  items.forEach((name, qty) {
    if (qty > 0) {
      itemsList.add({"name": name, "qty": qty});
    }
  });

  final requestBody = {
    "branch_id": branchId,
    "pickup_address": pickupAddress,
    "pickup_date": pickupDate,
    "pickup_time": pickupTime,
    "instructions": instructions,
    "basket_size": basketSize,
    "estimated_min": estimatedMin,
    "estimated_max": estimatedMax,
    "items": itemsList,
  };

  debugPrint('📤 Sending request to: $baseUrl/orders');
  debugPrint('📤 Headers: Authorization: Bearer ${token.substring(0, 20)}...');
  debugPrint('📤 Body: ${jsonEncode(requestBody)}');

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(requestBody),
    );

    debugPrint('📥 Status Code: ${response.statusCode}');
    debugPrint('📥 Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      // Show the actual error from Laravel
      throw Exception('Server error (${response.statusCode}): ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
    rethrow;
  }
}

  /// Get all orders for the authenticated user
  Future<List<dynamic>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("No authentication token found. Please login.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["orders"] ?? data;
    } else {
      throw Exception(data["message"] ?? "Failed to fetch orders");
    }
  }

  /// Get a specific order by ID
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("No authentication token found. Please login.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/orders/$orderId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Failed to fetch order");
    }
  }
}
