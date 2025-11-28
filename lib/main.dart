import 'package:flutter/material.dart';

// Your original splash screen import
import 'screens/splash_screen.dart';
import 'screens/forgot_password.dart';
// Added imports you will need for navigation
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());   // You already had this
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // You originally had this title
      title: 'Splash Demo',

      // You originally had this as the first page
      home: const SplashScreen(),

      // Added route system (does NOT replace or remove anything you had)
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/password': (_) => PasswordRecoveryScreen(),
        '/otp': (_) => OtpVerificationScreen(),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}
