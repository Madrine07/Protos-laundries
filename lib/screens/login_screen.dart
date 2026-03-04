// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> passwordVisible = ValueNotifier(false);
  final ValueNotifier<bool> rememberMe = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  final ApiService api = ApiService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordVisible.dispose();
    rememberMe.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  void _signIn() async {
  errorMessage.value = null;

  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    errorMessage.value = "Please fill all fields!";
    return;
  }

  if (_formKey.currentState!.validate()) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await api.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      // ── Save token and user info always ──────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      await prefs.setString('user_role', response['user']['role'] ?? 'customer');
      await prefs.setInt('user_id', response['user']['id']);

      // ── Save FCM token to backend now that we're logged in ──
      final fcmToken = prefs.getString('fcm_token_temp');
      if (fcmToken != null) {
        await _saveFcmTokenToBackend(fcmToken, response['token']);
      }

      final userRole = response["user"]["role"] ?? "customer";
      log("User logged in with role: $userRole");

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      errorMessage.value = e.toString();
      log("Login error: $e", name: "LoginScreen");
    }
  }
}

Future<void> _saveFcmTokenToBackend(String fcmToken, String authToken) async {
  try {
    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/update-fcm-token'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  } catch (e) {
    log('FCM token save error: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: Image.asset('images/final-no-background.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WELCOME ABOARD!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60), // moves form slightly down

            // --- Form ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Message
                      ValueListenableBuilder<String?>(
                        valueListenable: errorMessage,
                        builder: (context, value, _) {
                          if (value == null) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),

                      // Email & Password Fields
                      _buildTextField("Email", Icons.email_outlined, emailController),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: passwordVisible,
                        builder: (context, visible, _) {
                          return _buildTextField(
                            "Password",
                            Icons.lock_outline,
                            passwordController,
                            obscureText: !visible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                visible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                passwordVisible.value = !passwordVisible.value;
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // --- Remember Me + Forgot Password ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Remember Me
                          ValueListenableBuilder<bool>(
                            valueListenable: rememberMe,
                            builder: (context, value, _) {
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: value,
                                      onChanged: (v) {
                                        rememberMe.value = v ?? false;
                                      },
                                      activeColor: Colors.deepPurple,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Remember Me",
                                    style: TextStyle(
                                      fontSize: 12, // smaller font
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/password');
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 12, // smaller font
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sign Up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Text Field Helper ---
  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool obscureText = false, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
