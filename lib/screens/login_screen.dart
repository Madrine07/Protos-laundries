import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Notifiers
  final ValueNotifier<bool> passwordVisible = ValueNotifier(false);
  final ValueNotifier<bool> rememberMe = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  void _signIn(BuildContext context) {
    errorMessage.value = null;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = "Please fill all fields!";
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Navigate to home on Sign In
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER WITH LOGO & GRADIENT ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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

            const SizedBox(height: 20),

            // --- FORM ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          _buildTextField(
                            labelText: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                          ),
                          const SizedBox(height: 16),

                          ValueListenableBuilder<bool>(
                            valueListenable: passwordVisible,
                            builder: (context, visible, _) {
                              return _buildTextField(
                                labelText: "Password",
                                icon: Icons.lock_outline,
                                controller: passwordController,
                                obscureText: !visible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: () {
                                    passwordVisible.value =
                                        !passwordVisible.value;
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: rememberMe,
                                builder: (context, value, _) {
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: value,
                                        onChanged: (bool? v) {
                                          rememberMe.value = v ?? false;
                                        },
                                      ),
                                      const Text('Remember me'),
                                    ],
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/password');
                                },
                                child: const Text(
                                  'Forgot password ?',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () => _signIn(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // --- Bottom login area ---
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          const Center(child: Text('Or Sign In with')),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.g_mobiledata, size: 28),
                              ),
                              SizedBox(width: 16),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.facebook,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --- Bottom Sign Up Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to register on Sign Up
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- Styled TextField ---
  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          suffixIcon: suffixIcon,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText is required';
          }
          return null;
        },
      ),
    );
  }
}
