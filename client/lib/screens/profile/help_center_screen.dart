import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I download my digital ticket?',
      'a': 'You can download your digital ticket directly from the "Bookings" tab in your profile. Once the purchase is confirmed, a ticket will be generated, and a mobile-optimized QR code will be available for scannability at the venue entrance.',
    },
    {
      'q': 'Can I transfer my ticket to a friend?',
      'a': 'Currently, tickets are non-transferable and are linked to the person details provided during booking. Contact support for special cases.',
    },
    {
      'q': 'What is the refund policy for cancelled events?',
      'a': 'If an event is cancelled by the organizer, you will receive a full refund within 7-10 business days. For user-initiated cancellations, refund policies vary by event.',
    },
    {
      'q': 'How do I change my booking date?',
      'a': 'Date changes depend on the booking type. For parks and events, you can contact support to request a date change. Movie and transport bookings cannot be modified.',
    },
    {
      'q': 'Is my payment information secure?',
      'a': 'Yes, all payments are processed through Stripe which uses bank-level 256-bit SSL encryption. We never store your card details on our servers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const Text('TicketHub',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('How can we help?',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                    'Find answers to your questions about bookings, payments, and event access.',
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
              ),
              const SizedBox(height: 20),

              // Quick links
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _quickLink(Icons.confirmation_number, 'Booking\nHelp', AppColors.primary),
                    const SizedBox(width: 10),
                    _quickLink(Icons.payment, 'Payments', const Color(0xFFC49B63)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _quickLink(Icons.replay, 'Refunds\nPolicies & status', AppColors.textGrey),
              ),
              const SizedBox(height: 30),

              // FAQs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Frequently Asked Questions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              ...List.generate(_faqs.length, (index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(faq['q']!,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(faq['a']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                  height: 1.6)),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 30),

              // Support card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Still need assistance?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Our team is available 24/7 to help you with any booking issues.',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Email Support',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickLink(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}