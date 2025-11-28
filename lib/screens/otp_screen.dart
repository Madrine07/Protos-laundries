import 'package:flutter/material.dart';
import 'dart:async';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});

  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(30);
  final ValueNotifier<bool> canResend = ValueNotifier<bool>(false);
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  void startTimer() {
    canResend.value = false;
    remainingSeconds.value = 30;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value == 0) {
        canResend.value = true;
        timer.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Start timer when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔑 OTP ICON
                const Icon(
                  Icons.password_rounded,
                  size: 70,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 15),

                const Text(
                  "Verify OTP",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter the 6-digit code sent to your number",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                // 🔢 OTP TEXTFIELDS
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
                            borderRadius: BorderRadius.circular(12),
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

                const SizedBox(height: 25),

                // ⏳ TIMER + RESEND
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
                                color:
                                    resendAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // RESEND BUTTON
                            TextButton(
                              onPressed: resendAvailable
                                  ? () {
                                      startTimer();
                                    }
                                  : null,
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

                // ✔ VERIFY BUTTON
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Verify OTP",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
