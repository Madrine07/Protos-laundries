// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'screens/payment_screen.dart';
import 'screens/schedule_pickup.dart';
import 'screens/splash_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCRqa1rsGRehlK8go9jUNS3aAUECeHBkY4",
      authDomain: "protos-laundries.firebaseapp.com",
      projectId: "protos-laundries",
      storageBucket: "protos-laundries.firebasestorage.app",
      messagingSenderId: "364294517278",
      appId: "1:364294517278:web:ebef389ba1b472bf09340f",
      measurementId: "G-0WEH10LGW6",
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get FCM token — paste your VAPID key below
  String? token = await messaging.getToken(
    vapidKey: "BHICU4Bwv8SZzHTdGXQ-Y81q7aV1zOOg0qm3RliTCPAPT_2Pq2O3_4D2gK6x-rsRiXYBhj92wnPg9f2hhgm7i-Y", // ← replace this
  );

  print('FCM Token: $token');

  if (token != null) {
    await _saveFcmToken(token);
  }

  // Refresh token listener
  messaging.onTokenRefresh.listen(_saveFcmToken);

  // Foreground notification listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    // We will show this in the notifications screen later
  });

  runApp(const MyApp());
}

Future<void> _saveFcmToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken == null) return; // not logged in yet

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/update-fcm-token'), // ← update for production
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'fcm_token': token}),
    );

    print('FCM token saved: ${response.statusCode}');
  } catch (e) {
    print('FCM token save error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Protos Laundries',
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/password': (_) => PasswordRecoveryScreen(),
        '/home': (_) => HomeScreen(),
        '/schedule': (_) => SchedulePickupScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          final invoice = settings.arguments as OrderInvoice;
          return MaterialPageRoute(
            builder: (_) => OrderInvoiceScreen(invoice: invoice),
          );
        }
        return null;
      },
    );
  }
}