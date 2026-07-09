import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_names.dart';
import 'core/theme/app_theme.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51Tp9LiHrUeFBM6o1doBtPqcw64McQWxIHIwBzmZIgn0UzaDTVqkSgPfmlITKt5Q5gxagIFDRjZJf38s9YlKyUBBQ00YTzqeMdA';
  // Initialize Stripe
  await Stripe.instance.applySettings();

  // ✅ Initialize Local Notifications
  await LocalNotificationService.initialize();

  // Request permissions
  await _requestPermissions();

  runApp(const TicketHubApp());
}

Future<void> _requestPermissions() async {
  await Permission.photos.request();
  await Permission.storage.request();
  await Permission.notification.request();
}

class TicketHubApp extends StatelessWidget {
  const TicketHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicketHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // ✅ Navigator key for notification click
      navigatorKey: navigatorKey,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}