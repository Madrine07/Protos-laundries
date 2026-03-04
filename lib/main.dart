// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/contact_support_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/schedule_pickup.dart';
import 'screens/splash_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_invoice_id.dart';
import 'screens/account_screen.dart';
import 'screens/branches_screen.dart';

// ← Must be at top level, outside everything
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  String? token = await messaging.getToken(
    vapidKey:
        "BHICU4Bwv8SZzHTdGXQ-Y81q7aV1zOOg0qm3RliTCPAPT_2Pq2O3_4D2gK6x-rsRiXYBhj92wnPg9f2hhgm7i-Y",
  );

  print('FCM Token: $token');

  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token_temp', token);
    await _saveFcmToken(token);
  }

  messaging.onTokenRefresh.listen(_saveFcmToken);

  // Foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final orderId = message.data['order_id'];

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              entry.remove(); // dismiss on tap
              if (orderId != null) {
                navigatorKey.currentState?.pushNamed('/orders');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6B21A8),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          body,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => entry.remove(), // X button to dismiss
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  });

  // When user taps notification and app opens
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final orderId = message.data['order_id'];
    if (orderId != null) {
      navigatorKey.currentState?.pushNamed(
        '/payment',
        arguments: int.parse(orderId),
      );
    }
  });

  runApp(const MyApp());
}

Future<void> _saveFcmToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken == null) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/update-fcm-token'),
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
      navigatorKey: navigatorKey, // ← connects the key
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
        '/orders': (_) => const OrdersScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/account': (_) => const AccountScreen(),
        '/branches': (context) => const BranchesScreen(),
        '/support': (context) => const SupportScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          if (settings.arguments is OrderInvoice) {
            final invoice = settings.arguments as OrderInvoice;
            return MaterialPageRoute(
              builder: (_) => OrderInvoiceScreen(invoice: invoice),
            );
          }
          if (settings.arguments is int) {
            final orderId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => OrderInvoiceFromId(orderId: orderId),
            );
          }
        }
        return null;
      },
    );
  }
}
