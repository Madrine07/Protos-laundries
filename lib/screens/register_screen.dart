// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import 'dart:developer';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color purple = Color(0xFF6B21A8);
  static const Color gold   = Color(0xFFD4AF37);

  final TextEditingController fullNameController    = TextEditingController();
  final TextEditingController emailController       = TextEditingController();
  final TextEditingController contactController     = TextEditingController();
  final TextEditingController passwordController    = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final ValueNotifier<bool> passwordVisible        = ValueNotifier(false);
  final ValueNotifier<bool> confirmPasswordVisible = ValueNotifier(false);

  final ApiService api = ApiService();
  bool _loading    = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    passwordVisible.dispose();
    confirmPasswordVisible.dispose();
    super.dispose();
  }

  bool hasMinLength(String t) => t.length >= 8;
  bool hasUpper(String t)     => RegExp(r'[A-Z]').hasMatch(t);
  bool hasLower(String t)     => RegExp(r'[a-z]').hasMatch(t);
  bool hasNumber(String t)    => RegExp(r'[0-9]').hasMatch(t);
  bool hasSymbol(String t)    => RegExp(r'[!@#\$&*~^%]').hasMatch(t);

  void _register() async {
    if (fullNameController.text.isEmpty || emailController.text.isEmpty ||
        contactController.text.isEmpty  || passwordController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      _snack('Please fill all fields', isError: true); return;
    }
    if (passwordController.text != confirmPassController.text) {
      _snack('Passwords do not match', isError: true); return;
    }
    final pw = passwordController.text;
    if (!(hasMinLength(pw) && hasUpper(pw) && hasLower(pw) && hasNumber(pw) && hasSymbol(pw))) {
      _snack('Password must be at least 8 characters with uppercase, lowercase, number, and symbol', isError: true); return;
    }

    setState(() => _submitting = true);
    try {
      await api.requestOtp(
        name:     fullNameController.text.trim(),
        email:    emailController.text.trim(),
        password: pw,
      );
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => OtpVerificationScreen(
        name:               fullNameController.text.trim(),
        email:              emailController.text.trim(),
        password:           pw,
        isPasswordRecovery: false, // registration flow
      )));
    } catch (e) {
      if (!mounted) return;
      _snack('Error: ${e.toString()}', isError: true);
      log('OTP request error: $e', name: 'RegisterScreen');
    } finally {
      if (mounted) setState(() => _submitting = false);
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 32),
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(width: 200, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 8),
          Container(width: 260, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7))),
          const SizedBox(height: 32),
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          )),
          Container(height: 52, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
        ]),
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
                    const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Join Protos Laundries today', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                  ]),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_add_rounded, color: purple, size: 28)),
                        const SizedBox(height: 14),
                        const Text("Let's get you started", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 6),
                        const Text('Fill in your details to create an account', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                        const SizedBox(height: 28),
                        _buildField('Full Name', Icons.person_outline_rounded, fullNameController),
                        const SizedBox(height: 14),
                        _buildField('Email Address', Icons.email_outlined, emailController, keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _buildField('Contact Number', Icons.phone_outlined, contactController, keyboard: TextInputType.phone),
                        const SizedBox(height: 14),
                        ValueListenableBuilder<bool>(
                          valueListenable: passwordVisible,
                          builder: (context, visible, _) => _buildField('Password', Icons.lock_outline, passwordController,
                            obscure: !visible,
                            suffix: IconButton(icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: purple, size: 20), onPressed: () => passwordVisible.value = !passwordVisible.value),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPasswordStrength(),
                        const SizedBox(height: 14),
                        ValueListenableBuilder<bool>(
                          valueListenable: confirmPasswordVisible,
                          builder: (context, visible, _) => _buildField('Confirm Password', Icons.lock_outline, confirmPassController,
                            obscure: !visible,
                            suffix: IconButton(icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: purple, size: 20), onPressed: () => confirmPasswordVisible.value = !confirmPasswordVisible.value),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _register,
                            style: ElevatedButton.styleFrom(backgroundColor: gold, disabledBackgroundColor: gold.withOpacity(0.6), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: _submitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A0A2E)))
                                : const Text('Create Account', style: TextStyle(color: Color(0xFF1A0A2E), fontWeight: FontWeight.w800, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('Already have an account?', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          GestureDetector(onTap: () => Navigator.pushNamed(context, '/login'), child: const Text(' Sign In', style: TextStyle(fontSize: 13, color: purple, fontWeight: FontWeight.w700))),
                        ]),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller,
      {bool obscure = false, Widget? suffix, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller, obscureText: obscure, keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: label, hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Icon(icon, color: purple, size: 20), suffixIcon: suffix,
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEDE9F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: purple, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return ValueListenableBuilder(
      valueListenable: passwordController,
      builder: (context, value, _) {
        final text = value.text;
        if (text.isEmpty) return const SizedBox();
        final checks = [
          {'label': 'At least 8 characters',          'ok': hasMinLength(text)},
          {'label': 'Uppercase & lowercase letters',  'ok': hasUpper(text) && hasLower(text)},
          {'label': 'Contains a number',              'ok': hasNumber(text)},
          {'label': 'Contains a symbol (!@#\$&*~^%)', 'ok': hasSymbol(text)},
        ];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDE9F6))),
          child: Column(children: checks.map((c) {
            final passed = c['ok'] as bool;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Icon(passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: passed ? const Color(0xFF059669) : const Color(0xFFD1D5DB)),
                const SizedBox(width: 8),
                Text(c['label'] as String, style: TextStyle(fontSize: 12, color: passed ? const Color(0xFF059669) : const Color(0xFF6B7280))),
              ]),
            );
          }).toList()),
        );
      },
    );
  }
}