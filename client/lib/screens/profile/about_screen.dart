import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const Text('About TicketHub',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.confirmation_number,
                    color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 12),
              const Text('TicketHub',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const Text('One app. Every ticket.',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
              const SizedBox(height: 6),
              const Text('Version 1.0.0',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight)),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'TicketHub is your all-in-one ticket booking platform. Book movies, buses, trains, flights, sports events, concerts, theme parks and more — all from one app.\n\n'
                  'Built with Flutter and Node.js, TicketHub provides a seamless booking experience with real-time seat selection, secure Stripe payments, and instant e-ticket generation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textGrey, height: 1.6),
                ),
              ),
              const SizedBox(height: 30),

              _infoTile('Developer', 'TicketHub Team'),
              _infoTile('Technology', 'Flutter + Node.js + PostgreSQL'),
              _infoTile('Payment', 'Stripe Integration'),
              _infoTile('Contact', 'support@tickethub.com.pk'),
              const SizedBox(height: 30),

              const Text('EXCELLENCE IN EVERY ARRIVAL',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textGrey,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}