// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'dart:developer';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const NewPasswordScreen({required this.email, required this.otp, super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final TextEditingController newPasswordController     = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ValueNotifier<bool>   newPasswordVisible        = ValueNotifier(false);
  final ValueNotifier<bool>   confirmPasswordVisible    = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage             = ValueNotifier(null);

  final ApiService api = ApiService();
  bool _loading    = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordVisible.dispose();
    confirmPasswordVisible.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  bool hasMinLength(String t) => t.length >= 8;
  bool hasUpper(String t)     => RegExp(r'[A-Z]').hasMatch(t);
  bool hasLower(String t)     => RegExp(r'[a-z]').hasMatch(t);
  bool hasNumber(String t)    => RegExp(r'[0-9]').hasMatch(t);
  bool hasSymbol(String t)    => RegExp(r'[!@#\$&*~^%]').hasMatch(t);

  void _resetPassword() async {
    errorMessage.value = null;
    final pw        = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (pw.isEmpty || confirmPw.isEmpty) { errorMessage.value = 'Please fill all fields!'; return; }
    if (pw != confirmPw) { errorMessage.value = 'Passwords do not match!'; return; }
    if (!(hasMinLength(pw) && hasUpper(pw) && hasLower(pw) && hasNumber(pw) && hasSymbol(pw))) {
      errorMessage.value = 'Password must be at least 8 characters with uppercase, lowercase, number, and symbol';
      return;
    }

    setState(() => _submitting = true);
    try {
      await api.resetPassword(email: widget.email, otp: widget.otp, password: pw, confirmPassword: confirmPw);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully! Please login.'), backgroundColor: Colors.green),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      errorMessage.value = e.toString();
      log('Reset password error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            Container(width: 200, height: 22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 8),
            Container(width: 280, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 32),
            Container(width: double.infinity, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 16),
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Reset Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Create a new secure password', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                  ]),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.lock_reset_rounded, color: purple, size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text('Set New Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 8),
                          const Text('Enter your new password and confirm it below.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
                          const SizedBox(height: 32),

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

                          // New password
                          ValueListenableBuilder<bool>(
                            valueListenable: newPasswordVisible,
                            builder: (context, visible, _) {
                              return _buildField('New Password', Icons.lock_outline, newPasswordController,
                                obscure: !visible,
                                suffix: IconButton(
                                  icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: purple, size: 20),
                                  onPressed: () => newPasswordVisible.value = !newPasswordVisible.value,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm password
                          ValueListenableBuilder<bool>(
                            valueListenable: confirmPasswordVisible,
                            builder: (context, visible, _) {
                              return _buildField('Confirm Password', Icons.lock_outline, confirmPasswordController,
                                obscure: !visible,
                                suffix: IconButton(
                                  icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: purple, size: 20),
                                  onPressed: () => confirmPasswordVisible.value = !confirmPasswordVisible.value,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                disabledBackgroundColor: gold.withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _submitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0A2E)))
                                  : const Text('Reset Password', style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller,
      {bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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