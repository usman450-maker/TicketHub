import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_names.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey = '';
  await Stripe.instance.applySettings();

  // Request permissions on start
  await _requestPermissions();

  runApp(const TicketHubApp());
}

Future<void> _requestPermissions() async {
  // Request gallery/photos permission
  await Permission.photos.request();
  await Permission.storage.request();
}

class TicketHubApp extends StatelessWidget {
  const TicketHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicketHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}