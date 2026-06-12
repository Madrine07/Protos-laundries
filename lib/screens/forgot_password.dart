// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'dart:developer';
import 'otp_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<String?> errorMessage   = ValueNotifier(null);
  final ApiService api = ApiService();

  bool _loading    = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Brief shimmer on load
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    errorMessage.value = null;
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Please enter your email address';
      return;
    }

    setState(() => _submitting = true);

    try {
      await api.sendPasswordRecoveryOtp(emailController.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            name: '',
            email: emailController.text.trim(),
            password: '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      errorMessage.value = e.toString();
      log('Password recovery error: $e');
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
            Container(width: 200, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 10),
            Container(width: 280, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 6),
            Container(width: 240, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
            const SizedBox(height: 32),
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
                gradient: LinearGradient(
                  colors: [Color(0xFF6B21A8), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password Recovery',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Reset your account password',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon + title
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.lock_reset_rounded, color: purple, size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text('Forgot your password?',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the email address linked to your account. We\'ll send you an OTP to reset your password.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                          ),

                          const SizedBox(height: 32),

                          // Error message
                          ValueListenableBuilder<String?>(
                            valueListenable: errorMessage,
                            builder: (context, value, _) {
                              if (value == null) return const SizedBox();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(value,
                                      style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500))),
                                ]),
                              );
                            },
                          ),

                          // Email field
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Enter your email address',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                              prefixIcon: const Icon(Icons.email_outlined, color: purple),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFEDE9F6))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: purple, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Submit button
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                disabledBackgroundColor: gold.withOpacity(0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _submitting
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0A2E)))
                                  : const Text('Send OTP',
                                      style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800, fontSize: 15)),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Back to login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Remembered your password?',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(' Sign In',
                                    style: TextStyle(fontSize: 13, color: purple, fontWeight: FontWeight.w700)),
                              ),
                            ],
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
}