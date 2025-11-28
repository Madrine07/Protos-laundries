// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String? _errorMessage;

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   void _signUp() {
//     setState(() => _errorMessage = null);

//     if (nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         passwordController.text.isEmpty) {
//       setState(() {
//         _errorMessage = "Please fill all fields!";
//       });
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Processing Registration...')),
//       );
//       // Add navigation or API call here
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final height = constraints.maxHeight;

//               final logoSectionHeight = height * 0.2;
//               final titleSpacing = height * 0.01;
//               final formTopSpacing = height * 0.02;
//               final bottomSpacing = height * 0.02;

//               return SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: height),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       children: [
//                         // Logo section
//                         SizedBox(
//                           height: logoSectionHeight,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 height: logoSectionHeight * 1.0,
//                                 child: FittedBox(
//                                   fit: BoxFit.contain,
//                                   child: Image.asset('images/noback.png'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(height: titleSpacing),

//                         // Title texts
//                         const Text(
//                           'Create New Account',
//                           style: TextStyle(
//                               fontSize: 22, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         const Text(
//                           'Sign up to get started',
//                           style: TextStyle(fontSize: 14, color: Colors.black54),
//                         ),

//                         SizedBox(height: formTopSpacing),

//                         // Form
//                         Expanded(
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (_errorMessage != null)
//                                       Padding(
//                                         padding: const EdgeInsets.only(bottom: 12),
//                                         child: Text(
//                                           _errorMessage!,
//                                           style: const TextStyle(
//                                               color: Colors.red,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ),

//                                     _buildTextField(
//                                         labelText: "Full Name",
//                                         icon: Icons.person_outline,
//                                         controller: nameController),
//                                     SizedBox(height: height * 0.02),

//                                     _buildTextField(
//                                         labelText: "Email",
//                                         icon: Icons.email_outlined,
//                                         controller: emailController),
//                                     SizedBox(height: height * 0.02),

//                                     _buildPasswordField(
//                                         labelText: "Password",
//                                         controller: passwordController),
//                                     SizedBox(height: height * 0.03),

//                                     // Sign Up Button
//                                     SizedBox(
//                                       width: double.infinity,
//                                       child: ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 14),
//                                           backgroundColor: Colors.deepPurple,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                         onPressed: _signUp,
//                                         child: const Text(
//                                           'Sign Up',
//                                           style: TextStyle(
//                                               fontSize: 16, color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 // Bottom: Socials + Sign In
//                                 Column(
//                                   children: [
//                                     const SizedBox(height: 8),
//                                     const Center(child: Text('Or Sign Up With')),
//                                     const SizedBox(height: 12),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: const [
//                                         CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor: Colors.white,
//                                           child: Icon(Icons.g_mobiledata, size: 28),
//                                         ),
//                                         SizedBox(width: 16),
//                                         CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor: Colors.white,
//                                           child: Icon(Icons.facebook,
//                                               size: 28, color: Colors.blue),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: height * 0.02),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         const Text("Already have an account?"),
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.pushReplacement(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (_) =>
//                                                       const LoginScreen()),
//                                             );
//                                           },
//                                           child: const Text(
//                                             'Sign In',
//                                             style: TextStyle(
//                                                 color: Colors.deepPurple),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         SizedBox(height: bottomSpacing),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String labelText,
//     required IconData icon,
//     required TextEditingController controller,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: labelText,
//           prefixIcon: Icon(icon, color: Colors.deepPurple),
//           filled: true,
//           fillColor: Colors.grey[200],
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return '$labelText is required';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildPasswordField({
//     required String labelText,
//     required TextEditingController controller,
//   }) {
//     return _PasswordTextField(controller: controller);
//   }
// }

// class _PasswordTextField extends StatefulWidget {
//   final TextEditingController controller;
//   const _PasswordTextField({required this.controller});

//   @override
//   State<_PasswordTextField> createState() => __PasswordTextFieldState();
// }

// class __PasswordTextFieldState extends State<_PasswordTextField> {
//   bool _obscureText = true;

//   void _toggleVisibility() => setState(() => _obscureText = !_obscureText);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       child: TextFormField(
//         controller: widget.controller,
//         obscureText: _obscureText,
//         decoration: InputDecoration(
//           labelText: "Password",
//           prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepPurple),
//           filled: true,
//           fillColor: Colors.grey[200],
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscureText
//                   ? Icons.visibility_off_outlined
//                   : Icons.visibility_outlined,
//               color: Colors.grey,
//             ),
//             onPressed: _toggleVisibility,
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) return 'Password is required';
//           if (value.length < 8) return 'Password must be at least 8 characters';
//           return null;
//         },
//       ),
//     );
//   }
// }

// Flutter UI Clone – Create Password Screen (Inspo)
// StatelessWidget version, matching your coding style

// import 'package:flutter/material.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final height = constraints.maxHeight;
//           final width = constraints.maxWidth;

//           return Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.deepPurple, Colors.purple],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: SafeArea(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: width * 0.07,
//                     vertical: height * 0.03,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(height: height * 0.04),

//                       SizedBox(
//                         height: height * 0.15,
//                         child: Image.asset(
//                           'images/noback.png',
//                           fit: BoxFit.contain,
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       const Text(
//                         "Create Password",
//                         style: TextStyle(
//                           fontSize: 26,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       const Text(
//                         "Your password must be at least 8 characters",
//                         style: TextStyle(fontSize: 14, color: Colors.white70),
//                         textAlign: TextAlign.center,
//                       ),

//                       SizedBox(height: height * 0.05),

//                       const PasswordField(label: "Password"),
//                       SizedBox(height: height * 0.025),
//                       const PasswordField(label: "Confirm Password"),

//                       SizedBox(height: height * 0.04),

//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: height * 0.018),
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/home');
//                           },
//                           child: Text(
//                             "Complete Setup",
//                             style: TextStyle(
//                               fontSize: width * 0.045,
//                               color: Colors.deepPurple,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: height * 0.03),

//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Text(
//                           "Back to Login",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class PasswordField extends StatefulWidget {
//   final String label;
//   const PasswordField({required this.label, super.key});

//   @override
//   State<PasswordField> createState() => _PasswordFieldState();
// }

// class _PasswordFieldState extends State<PasswordField> {
//   bool hide = true;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       obscureText: hide,
//       decoration: InputDecoration(
//         labelText: widget.label,
//         filled: true,
//         fillColor: Colors.white,
//         prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
//         suffixIcon: IconButton(
//           icon: Icon(hide ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
//           onPressed: () => setState(() => hide = !hide),
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return '${widget.label} is required';
//         if (value.length < 8) return 'Password must be at least 8 characters';
//         return null;
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         fontFamily: 'Roboto',
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const RegisterScreen(),
//         '/home': (context) => Scaffold(
//           // appBar: AppBar(title: Text('Home Screen')),
//           body: Center(child: Text('Setup Complete!')),
//         ),
//       },
//     );
//   }
// }

// //
// // ────────────────────────────────────────────────────────────────
// //  REUSABLE WIDGET: STANDARD FORM FIELD
// // ────────────────────────────────────────────────────────────────
// //

// class CustomFormField extends StatelessWidget {
//   final String label;
//   final String hint;
//   final bool isOptional;
//   final TextInputType keyboardType;

//   const CustomFormField({
//     required this.label,
//     required this.hint,
//     this.isOptional = false,
//     this.keyboardType = TextInputType.text,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const labelColor = Color(0xFF4C5760);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isOptional ? '$label (Optional)' : label,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: labelColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           keyboardType: keyboardType,
//           decoration: _inputDecoration(hint),
//           validator: (value) {
//             if (!isOptional && (value == null || value.isEmpty)) {
//               return '$label is required';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }
// }

// //
// // ────────────────────────────────────────────────────────────────
// //  PASSWORD FIELD WITH VISIBILITY TOGGLE
// // ────────────────────────────────────────────────────────────────
// //

// class PasswordTextField extends StatefulWidget {
//   final String label;
//   final String hint;
//   final TextEditingController? controller;

//   const PasswordTextField({
//     required this.label,
//     required this.hint,
//     this.controller,
//     super.key,
//   });

//   @override
//   State<PasswordTextField> createState() => _PasswordTextFieldState();
// }

// class _PasswordTextFieldState extends State<PasswordTextField> {
//   bool hide = true;

//   @override
//   Widget build(BuildContext context) {
//     const labelColor = Color(0xFF4C5760);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: labelColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: widget.controller,
//           obscureText: hide,
//           decoration: _inputDecoration(widget.hint).copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                 hide ? Icons.visibility_off : Icons.visibility,
//               ),
//               onPressed: () => setState(() => hide = !hide),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return '${widget.label} is required';
//             }
//             if (value.length < 8) {
//               return 'Password must be at least 8 characters';
//             }
//             if (!RegExp(r'[0-9]').hasMatch(value) ||
//                 !RegExp(r'[a-zA-Z]').hasMatch(value)) {
//               return 'Must include numbers and letters';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }
// }

// //
// // ────────────────────────────────────────────────────────────────
// //  BULLET ITEM (PASSWORD REQUIREMENT)
// // ────────────────────────────────────────────────────────────────
// //

// class PasswordRequirementCheck extends StatelessWidget {
//   final String text;

//   const PasswordRequirementCheck({required this.text, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 6,
//           height: 6,
//           decoration: BoxDecoration(
//             color: Colors.grey,
//             borderRadius: BorderRadius.circular(3),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
//       ],
//     );
//   }
// }

// //
// // ────────────────────────────────────────────────────────────────
// //  MAIN REGISTER SCREEN
// // ────────────────────────────────────────────────────────────────
// //

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   static final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final passwordController = TextEditingController();

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final height = constraints.maxHeight;
//               final width = constraints.maxWidth;

//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     _header(height, width),
//                     _formCard(height, width, passwordController),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // Header Section
//   Widget _header(double height, double width) {
//     return Container(
//       height: height * 0.3,
//       padding: EdgeInsets.only(
//         left: width * 0.07,
//         top: height * 0.05,
//       ),
//       alignment: Alignment.centerLeft,
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Sign up",
//             style: TextStyle(
//               fontSize: 30,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             "Create an account to get started",
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white70,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Form Card
//   Widget _formCard(
//     double height,
//     double width,
//     TextEditingController passwordController,
//   ) {
//     return Container(
//       width: double.infinity,
//       constraints: BoxConstraints(minHeight: height * 0.7),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: width * 0.07,
//         vertical: height * 0.04,
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const CustomFormField(
//               label: "Full Name",
//               hint: "John Doe",
//             ),
//             SizedBox(height: height * 0.025),

//             const CustomFormField(
//               label: "Email",
//               hint: "john@example.com",
//               isOptional: true,
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: height * 0.025),

//             PasswordTextField(
//               label: "Create Password",
//               hint: "••••••••",
//               controller: passwordController,
//             ),
//             const SizedBox(height: 10),

//             const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 PasswordRequirementCheck(text: "At least 8 characters"),
//                 PasswordRequirementCheck(text: "Include numbers and letters"),
//               ],
//             ),
//             SizedBox(height: height * 0.03),

//             _confirmPasswordField(passwordController),
//             SizedBox(height: height * 0.04),

//             _completeButton(width, height),
//           ],
//         ),
//       ),
//     );
//   }

//   // Confirm Password
//   Widget _confirmPasswordField(TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Confirm Password",
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF4C5760),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           obscureText: true,
//           decoration: _inputDecoration("••••••••"),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Confirm Password is required';
//             }
//             if (value != controller.text) {
//               return 'Passwords do not match';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }

//   // Complete Setup Button
//   Widget _completeButton(double width, double height) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           padding: EdgeInsets.symmetric(vertical: height * 0.02),
//           backgroundColor: const Color(0xFF673AB7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 5,
//         ),
//         onPressed: () {
//           if (_formKey.currentState!.validate()) {
//             Navigator.pushNamed(_formKey.currentContext!, '/home');
//           }
//         },
//         child: Text(
//           "Complete Setup",
//           style: TextStyle(
//             fontSize: width * 0.045,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// //
// // ────────────────────────────────────────────────────────────────
// //  INPUT DECORATION (REUSED EVERYWHERE)
// // ────────────────────────────────────────────────────────────────
// //

// InputDecoration _inputDecoration(String hint) {
//   return InputDecoration(
//     hintText: hint,
//     filled: true,
//     fillColor: Colors.white,
//     contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Colors.grey),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
//     ),
//   );
// }

import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  // Password visibility notifiers
  final ValueNotifier<bool> passwordVisible = ValueNotifier(false);
  final ValueNotifier<bool> confirmPasswordVisible = ValueNotifier(false);

  // Password checks
  bool hasMinLength(String t) => t.length >= 8;
  bool hasUpper(String t) => RegExp(r"[A-Z]").hasMatch(t);
  bool hasLower(String t) => RegExp(r"[a-z]").hasMatch(t);
  bool hasNumber(String t) => RegExp(r"[0-9]").hasMatch(t);
  bool hasSymbol(String t) => RegExp(r"[!@#\$&*~^%]").hasMatch(t);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER WITH GRADIENT AND LOGO ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    child: Image.asset(
                      "images/final-no-background.png",
                      fit: BoxFit.contain,
                    ),
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

            // --- FORM SECTION ---
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
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
                      // Password
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
                      _passwordStrength(passwordController),
                      // Confirm Password
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
                                visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                          onPressed: () {
                            // Validate fields
                            if (fullNameController.text.isEmpty ||
                                contactController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                confirmPassController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please fill all fields",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            if (passwordController.text !=
                                confirmPassController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Passwords do not match",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // top margin 20, bottom 0
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            // Success snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "User registered successfully!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.fromLTRB(20, 20, 20, 0), // top margin 20, bottom 0
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Navigate immediately (safe in StatelessWidget)
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
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
            ),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
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

  // --- Password strength ---
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
