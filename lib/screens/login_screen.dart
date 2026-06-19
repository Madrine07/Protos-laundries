// ignore_for_file: use_build_context_synchronously, unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'notification_badge.dart';
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
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState>  _formKey           = GlobalKey<FormState>();
  final ValueNotifier<bool>   passwordVisible    = ValueNotifier(false);
  final ValueNotifier<bool>   rememberMe         = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage      = ValueNotifier(null);

  final ApiService api = ApiService();
  bool _loading        = true;
  bool _submitting     = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

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
      errorMessage.value = 'Please fill all fields!';
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final response = await api.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      await prefs.setString('user_role', response['user']['role'] ?? 'customer');
      await prefs.setInt('user_id', response['user']['id']);

      final fcmToken = prefs.getString('fcm_token_temp');
      if (fcmToken != null) {
        await _saveFcmTokenToBackend(fcmToken, response['token']);
      }

      // Refresh badge after login
      await NotificationBadge.refresh();

      log('User logged in with role: ${response['user']['role']}');
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      errorMessage.value = e.toString();
      log('Login error: $e', name: 'LoginScreen');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _saveFcmTokenToBackend(String fcmToken, String authToken) async {
    try {
      await http.post(
        Uri.parse('https://protos.dina-apartments.com/api/update-fcm-token'),
        headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    } catch (e) {
      log('FCM token save error: $e');
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(width: 180, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 8),
            Container(width: 260, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 40),
            Container(width: double.infinity, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(width: 110, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              Container(width: 110, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ]),
            const SizedBox(height: 24),
            Container(width: double.infinity, height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 50, height: 50, child: Image.asset('images/final-no-background.png')),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Back!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Sign in to continue', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error
                            ValueListenableBuilder<String?>(
                              valueListenable: errorMessage,
                              builder: (context, value, _) {
                                if (value == null) return const SizedBox();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(value, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500))),
                                  ]),
                                );
                              },
                            ),

                            // Email
                            _buildField('Email Address', Icons.email_outlined, emailController, keyboard: TextInputType.emailAddress),
                            const SizedBox(height: 16),

                            // Password
                            ValueListenableBuilder<bool>(
                              valueListenable: passwordVisible,
                              builder: (context, visible, _) {
                                return _buildField('Password', Icons.lock_outline, passwordController,
                                  obscure: !visible,
                                  suffix: IconButton(
                                    icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: purple, size: 20),
                                    onPressed: () => passwordVisible.value = !passwordVisible.value,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Remember me + Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: rememberMe,
                                  builder: (context, value, _) {
                                    return Row(children: [
                                      SizedBox(
                                        width: 18, height: 18,
                                        child: Checkbox(
                                          value: value,
                                          onChanged: (v) => rememberMe.value = v ?? false,
                                          activeColor: purple,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('Remember Me', style: TextStyle(fontSize: 12, color: Colors.black87)),
                                    ]);
                                  },
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/password'),
                                  child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: purple, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Sign in button
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purple,
                                  disabledBackgroundColor: purple.withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _submitting
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?", style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/register'),
                                  child: const Text(' Sign Up', style: TextStyle(fontSize: 13, color: purple, fontWeight: FontWeight.w700)),
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

  Widget _buildField(String label, IconData icon, TextEditingController controller,
      {bool obscure = false, Widget? suffix, TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Icon(icon, color: purple, size: 20),
        suffixIcon: suffix,
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEDE9F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: purple, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}