import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer';

class NewPasswordScreen extends StatefulWidget {
  final String email; // Email for which password is being reset
  final String otp;   // OTP received from previous screen

  const NewPasswordScreen({
    required this.email,
    required this.otp,
    super.key,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> newPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> confirmPasswordVisible = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  final ApiService api = ApiService();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordVisible.dispose();
    confirmPasswordVisible.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  // --- Password strength checks ---
  bool hasMinLength(String t) => t.length >= 8;
  bool hasUpper(String t) => RegExp(r"[A-Z]").hasMatch(t);
  bool hasLower(String t) => RegExp(r"[a-z]").hasMatch(t);
  bool hasNumber(String t) => RegExp(r"[0-9]").hasMatch(t);
  bool hasSymbol(String t) => RegExp(r"[!@#\$&*~^%]").hasMatch(t);

  void _resetPassword() async {
    errorMessage.value = null;

    final pw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (pw.isEmpty || confirmPw.isEmpty) {
      errorMessage.value = "Please fill all fields!";
      return;
    }

    if (pw != confirmPw) {
      errorMessage.value = "Passwords do not match!";
      return;
    }

    if (!(hasMinLength(pw) && hasUpper(pw) && hasLower(pw) && hasNumber(pw) && hasSymbol(pw))) {
      errorMessage.value =
          "Password must be at least 8 characters, include uppercase, lowercase, number, and symbol";
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call API to reset password
      await api.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: pw,
        confirmPassword: confirmPw,
      
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // hide spinner

      // Show success and navigate back to login
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully! Please login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // hide spinner
      errorMessage.value = e.toString();
      log("Reset password error: $e");
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
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // --- Form ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
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

                    // Instruction text
                    const Text(
                      "Enter your new password and confirm it below.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // New password field
                    ValueListenableBuilder<bool>(
                      valueListenable: newPasswordVisible,
                      builder: (context, visible, _) {
                        return _buildTextField(
                          "New Password",
                          Icons.lock_outline,
                          newPasswordController,
                          obscureText: !visible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              visible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              newPasswordVisible.value = !newPasswordVisible.value;
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    ValueListenableBuilder<bool>(
                      valueListenable: confirmPasswordVisible,
                      builder: (context, visible, _) {
                        return _buildTextField(
                          "Confirm Password",
                          Icons.lock_outline,
                          confirmPasswordController,
                          obscureText: !visible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              visible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              confirmPasswordVisible.value = !confirmPasswordVisible.value;
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // Reset password button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(color: Colors.white),
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

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
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
