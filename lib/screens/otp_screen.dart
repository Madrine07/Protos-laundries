// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'dart:developer';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final bool isPasswordRecovery;

  const OtpVerificationScreen({
    required this.email,
    this.name = '',
    this.password = '',
    this.isPasswordRecovery = false, // ← fixed: default is registration flow
    super.key,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final ValueNotifier<int>  remainingSeconds = ValueNotifier<int>(30);
  final ValueNotifier<bool> canResend        = ValueNotifier<bool>(false);
  Timer? _timer;
  bool _verifying = false;

  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    remainingSeconds.dispose();
    canResend.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    canResend.value = false;
    remainingSeconds.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value == 0) {
        canResend.value = true;
        timer.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void _verifyOtp() async {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _snack('Please enter the 6-digit OTP', isError: true);
      return;
    }

    setState(() => _verifying = true);
    try {
      if (widget.isPasswordRecovery) {
        // ── Password recovery flow ──
        await api.verifyPasswordOtp(email: widget.email, otp: otp);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NewPasswordScreen(email: widget.email, otp: otp)),
        );
      } else {
        // ── Registration flow ──
        final response = await api.verifyOtp(
          name: widget.name,
          email: widget.email,
          password: widget.password,
          otp: otp,
        );
        if (!mounted) return;
        final token = response['token'];
        log('User registered, token: $token');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Error: ${e.toString()}', isError: true);
      log('OTP verify error: $e');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _resendOtp() async {
    setState(() => _verifying = true);
    try {
      if (widget.isPasswordRecovery) {
        await api.sendPasswordRecoveryOtp(widget.email);
      } else {
        await api.resendOtp(email: widget.email);
      }
      if (!mounted) return;
      startTimer();
      _snack('OTP resent successfully');
    } catch (e) {
      if (!mounted) return;
      _snack('Error: ${e.toString()}', isError: true);
      log('OTP resend error: $e');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isRecovery = widget.isPasswordRecovery;

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
                      Text(
                        isRecovery ? 'Password Recovery' : 'Verify Your Email',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        isRecovery ? 'Enter OTP to reset password' : 'Enter OTP to complete registration',
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isRecovery ? Icons.lock_reset_rounded : Icons.mark_email_read_rounded,
                        color: purple, size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRecovery ? 'Check your email' : 'Almost there!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to '),
                          TextSpan(text: widget.email, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 46,
                          child: TextField(
                            controller: otpControllers[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E),
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFEDE9F6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: purple, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Resend timer
                    ValueListenableBuilder<bool>(
                      valueListenable: canResend,
                      builder: (context, resendAvailable, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: remainingSeconds,
                          builder: (context, seconds, _) {
                            return Column(
                              children: [
                                Text(
                                  resendAvailable
                                      ? 'You can now resend the code'
                                      : 'Resend code in $seconds seconds',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: resendAvailable ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: resendAvailable && !_verifying ? _resendOtp : null,
                                  child: Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: resendAvailable ? purple : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Verify button
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _verifying ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          disabledBackgroundColor: gold.withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _verifying
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0A2E)))
                            : Text(
                                isRecovery ? 'Verify & Reset Password' : 'Verify & Create Account',
                                style: const TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800, fontSize: 15),
                              ),
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
}