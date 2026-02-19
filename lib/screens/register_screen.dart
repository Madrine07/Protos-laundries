import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:developer';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controllers for all form fields ---
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  // --- Password visibility toggles ---
  final ValueNotifier<bool> passwordVisible = ValueNotifier(false);
  final ValueNotifier<bool> confirmPasswordVisible = ValueNotifier(false);

  final ApiService api = ApiService(); // API service instance

  @override
  void dispose() {
    // Dispose controllers and notifiers
    fullNameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    passwordVisible.dispose();
    confirmPasswordVisible.dispose();
    super.dispose();
  }

  // --- Password strength validation methods ---
  bool hasMinLength(String t) => t.length >= 8;
  bool hasUpper(String t) => RegExp(r"[A-Z]").hasMatch(t);
  bool hasLower(String t) => RegExp(r"[a-z]").hasMatch(t);
  bool hasNumber(String t) => RegExp(r"[0-9]").hasMatch(t);
  bool hasSymbol(String t) => RegExp(r"[!@#\$&*~^%]").hasMatch(t);

  /// Called when user clicks "Register"
  void _register() async {
    // --- Basic field validation ---
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        contactController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPassController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Password confirmation check ---
    if (passwordController.text != confirmPassController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Password strength validation ---
    String pw = passwordController.text;
    if (!(hasMinLength(pw) &&
        hasUpper(pw) &&
        hasLower(pw) &&
        hasNumber(pw) &&
        hasSymbol(pw))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 8 characters, include uppercase, lowercase, number, and symbol",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Show loading spinner while requesting OTP ---
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 🔑 Request OTP from backend API
      await api.requestOtp(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: pw,
      );

      // Hide loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Navigate to OTP verification screen, passing name, email, password
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            name: fullNameController.text.trim(),
            email: emailController.text.trim(),
            password: pw,
          ),
        ),
      );
    } catch (e) {
      // Hide loading dialog if error occurs
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show API error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      log("OTP request error: $e", name: "RegisterScreen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header with gradient and logo ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: Image.asset("images/final-no-background.png"),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    // --- Form fields ---
                    _buildTextField(
                      labelText: "Full Name",
                      icon: Icons.person,
                      controller: fullNameController,
                    ),
                    _buildTextField(
                      labelText: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboard: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      labelText: "Contact Number",
                      icon: Icons.phone,
                      controller: contactController,
                      keyboard: TextInputType.phone,
                    ),
                    // Password field with visibility toggle
                    ValueListenableBuilder(
                      valueListenable: passwordVisible,
                      builder: (context, visible, _) {
                        return _buildTextField(
                          labelText: "Password",
                          icon: Icons.lock_outline,
                          controller: passwordController,
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
                    // Password strength indicators
                    _passwordStrength(passwordController),
                    // Confirm password field with visibility toggle
                    ValueListenableBuilder(
                      valueListenable: confirmPasswordVisible,
                      builder: (context, visible, _) {
                        return _buildTextField(
                          labelText: "Confirm Password",
                          icon: Icons.lock_outline,
                          controller: confirmPassController,
                          obscureText: !visible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              visible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              confirmPasswordVisible.value =
                                  !confirmPasswordVisible.value;
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    // --- Register button ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _register, // calls OTP request flow
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15), // spacing before sign in link
                    // --- Already have an account? Sign In ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/login',
                            ); // navigate back to login
                          },
                          child: const Text(
                            "Sign In",
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
          ],
        ),
      ),
    );
  }

  // --- Helper to build text fields ---
  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: labelText,
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
      ),
    );
  }

  // --- Password strength UI indicator ---
  Widget _passwordStrength(TextEditingController controller) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        String text = value.text;
        final List<Map<String, dynamic>> checks = [
          {"label": "At least 8 characters", "ok": hasMinLength(text)},
          {
            "label": "Uppercase & lowercase letters",
            "ok": hasUpper(text) && hasLower(text),
          },
          {"label": "Contains a number", "ok": hasNumber(text)},
          {"label": "Contains a symbol (!@#\$&*~^%)", "ok": hasSymbol(text)},
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: checks.map((c) {
            final bool passed = c["ok"] as bool;
            final String label = c["label"] as String;
            return Row(
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: passed ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: passed ? Colors.green : Colors.grey.shade700,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
