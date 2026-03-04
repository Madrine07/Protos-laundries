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
        final token = prefs.getString("auth_token"); // ← fixed from "token"

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
        debugPrint('📤 Body: ${jsonEncode(requestBody)}');

        try {
          final response = await http.post(
            Uri.parse("$baseUrl/orders"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
            body: jsonEncode(requestBody),
          );

          debugPrint('📥 Status: ${response.statusCode}');
          debugPrint('📥 Body: ${response.body}');

          if (response.statusCode == 201) {
            return jsonDecode(response.body);
          } else {
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

      Future<Map<String, dynamic>> uploadPayment({
      required int orderId,
      required String paymentMethod,
      required List<int> screenshotBytes,
      required String screenshotName,
      String? transactionId,
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) throw Exception("Not logged in.");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/orders/$orderId/payment"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['payment_method'] = paymentMethod;
      if (transactionId != null) {
        request.fields['transaction_id'] = transactionId;
      }

      request.files.add(http.MultipartFile.fromBytes(
        'screenshot',
        screenshotBytes,
        filename: screenshotName,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Payment upload failed");
      }
    }

      Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("token");

        if (token == null) throw Exception("Not logged in.");

        final response = await http.get(
          Uri.parse("$baseUrl/orders/$orderId"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return data;
        } else {
          throw Exception(data["message"] ?? "Failed to fetch order");
        }
      }

      Future<List<dynamic>> getMyOrders() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/my-orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['orders'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch orders');
      }
    }

      Future<List<Map<String, dynamic>>> getBranches() async {
      final response = await http.get(
        Uri.parse('$baseUrl/branches'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((b) => {
          'id': b['id'] as int,
          'name': b['name'] as String,
          'location': b['location'] ?? '',
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    }

      Future<Map<String, dynamic>> cancelOrder(int orderId) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not logged in');

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Failed to cancel order');
    }

    Future<Map<String, dynamic>> rescheduleOrder({
      required int orderId,
      required String pickupDate,
      required String pickupTime,
      String? instructions,
      String? basketSize,
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not logged in');

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/reschedule'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pickup_date':  pickupDate,
          'pickup_time':  pickupTime,
          if (instructions != null) 'instructions': instructions,
          if (basketSize != null)   'basket_size':  basketSize,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return data;
      throw Exception(data['message'] ?? 'Failed to reschedule order');
    }

    Future<Map<String, int>> fetchPrices() async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/pricing'),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final Map<String, int> prices = {};
          for (final item in data) {
            prices[item['key']] = item['price'] as int;
          }
          return prices;
        }
      } catch (e) {
        debugPrint('Error fetching prices: $e');
      }

      // Fallback defaults
      return {
        'price_per_kg': 3000,
        'suit_2_piece': 15000,
        'suit_3_piece': 20000,
        'duvet':        22500,
        'curtain':      10000,
      };
    }
}
