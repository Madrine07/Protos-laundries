import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'dart:developer';
import 'new_password_screen.dart'; // For password recovery flow


class OtpVerificationScreen extends StatefulWidget {
  // Passed from previous screens
  final String email;
  final String name; // Only used for registration
  final String password; // Only used for registration
  final bool isPasswordRecovery; // true if forgot password flow

  const OtpVerificationScreen({
    required this.email,
    this.name = "",
    this.password = "",
    this.isPasswordRecovery = true,
    super.key,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(30);
  final ValueNotifier<bool> canResend = ValueNotifier<bool>(false);
  Timer? _timer;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    startTimer(); // Start OTP countdown
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

  /// Starts countdown for resending OTP
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

  /// Verify OTP for either registration or password recovery
  void _verifyOtp() async {
    final otp = otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter the 6-digit OTP"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (widget.isPasswordRecovery) {
        // --- Password recovery OTP verification ---
        await api.verifyPasswordOtp(email: widget.email, otp: otp);

        if (!mounted) return;
        Navigator.of(context).pop(); // hide spinner

        // Navigate to NewPasswordScreen to reset password
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(email: widget.email, otp: otp,),
          ),
        );
      } else {
        // --- Registration OTP verification ---
        final response = await api.verifyOtp(
          name: widget.name,
          email: widget.email,
          password: widget.password,
          otp: otp,
        );

        if (!mounted) return;
        Navigator.of(context).pop(); // hide spinner

        final token = response['token'];
        log("User token: $token");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // hide spinner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
      log("OTP verify error: $e");
    }
  }

  /// Resend OTP (for both registration and password recovery)
  void _resendOtp() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (widget.isPasswordRecovery) {
        await api.sendPasswordRecoveryOtp(widget.email);
      } else {
        await api.resendOtp(email: widget.email);
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // hide spinner

      startTimer();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("OTP resent successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
      log("OTP resend error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.password_rounded,
                    size: 70, color: Colors.deepPurple),
                const SizedBox(height: 15),
                Text(
                  widget.isPasswordRecovery ? "Password Recovery OTP" : "Verify OTP",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter the 6-digit code sent to your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                const SizedBox(height: 25),
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
                                  ? "You can now resend code"
                                  : "Resend code in $seconds seconds",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: resendAvailable ? Colors.green : Colors.red),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: resendAvailable ? _resendOtp : null,
                              child: Text(
                                "Resend OTP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: resendAvailable
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _verifyOtp,
                    child: const Text("Verify OTP",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
