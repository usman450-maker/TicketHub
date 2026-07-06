import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'transport_confirmed_screen.dart';

class TransportPaymentScreen extends StatefulWidget {
  final TransportBooking booking;

  const TransportPaymentScreen({super.key, required this.booking});

  @override
  State<TransportPaymentScreen> createState() => _TransportPaymentScreenState();
}

class _TransportPaymentScreenState extends State<TransportPaymentScreen> {
  bool _isProcessing = false;

Future<void> _handlePayment() async {
  setState(() => _isProcessing = true);

  try {
    print('💳 Creating payment intent...');
    
    // Step 1: Create payment intent
    final intentResponse = await TransportService.createPaymentIntent(
      amount: widget.booking.totalAmount,
    );
    
    print('💳 Intent response: $intentResponse');

    if (intentResponse['success'] != true) {
      throw Exception(intentResponse['message'] ?? 'Payment init failed');
    }

    final clientSecret = intentResponse['clientSecret'];
    final paymentIntentId = intentResponse['paymentIntentId'];

    // Step 2: Initialize Stripe payment sheet
    print('💳 Initializing payment sheet...');
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'TicketHub',
        style: ThemeMode.light,
      ),
    );

    // Step 3: Present payment sheet
    print('💳 Presenting payment sheet...');
    await Stripe.instance.presentPaymentSheet();
    
    print('💳 Payment successful! Confirming booking...');

    // Step 4: Confirm booking
    final confirmResponse = await TransportService.confirmBooking(
      bookingData: widget.booking.toJson(),
      paymentId: paymentIntentId,
    );
    
    print('💳 Confirm response: $confirmResponse');

    if (!mounted) return;

    if (confirmResponse['success'] == true) {
      CustomSnackbar.showSuccess(context, 'Payment successful!');
      
      // Get order number safely
      final orderNumber = confirmResponse['booking']?['order_number'] 
        ?? 'TH-${DateTime.now().millisecondsSinceEpoch}';
      
      print('✅ Navigating to confirmation with order: $orderNumber');
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TransportConfirmedScreen(
                booking: widget.booking,
                orderNumber: orderNumber,
              ),
            ),
          );
        }
      });
    } else {
      throw Exception(confirmResponse['message'] ?? 'Booking confirmation failed');
    }
  } on StripeException catch (e) {
    print('❌ Stripe error: ${e.error}');
    if (!mounted) return;
    CustomSnackbar.showError(context, e.error.localizedMessage ?? 'Payment cancelled');
  } catch (e, stack) {
    print('❌ Payment error: $e');
    print('Stack: $stack');
    if (!mounted) return;
    CustomSnackbar.showError(context, 'Error: $e');
  } finally {
    if (mounted) setState(() => _isProcessing = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F16),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFC49B63)),
                  ),
                  const Text(
                    'TicketHub',
                    style: TextStyle(
                      color: Color(0xFFC49B63),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Payment Method',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Stripe Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC49B63)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.credit_card, color: Color(0xFFC49B63), size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay with Stripe',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            'Credit/Debit Card',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                          color: Color(0xFFC49B63),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      b.operatorName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${b.fromLocation.split(",")[0]} to ${b.toLocation.split(",")[0]}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${b.departureDate} • ${b.departureTime}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Passengers: ${b.passengers.length}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    
                    // Seats display
                    if (b.seatNumbers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.event_seat,
                                color: Color(0xFFC49B63), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Seats: ${b.seatNumbers.join(", ")}',
                              style: const TextStyle(
                                color: Color(0xFFC49B63),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    
                    // ============================
                    // PRICES IN PKR (No conversion)
                    // ============================
                    _row('Base Price', 'PKR ${b.basePrice.toStringAsFixed(0)}'),
                    _row('Booking Fee (5%)', 'PKR ${b.bookingFee.toStringAsFixed(0)}'),
                    _row('Tax (10%)', 'PKR ${b.tax.toStringAsFixed(0)}'),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text(
                          'PKR ${b.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFFC49B63),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Pay Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC49B63),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'PAY NOW',
                                style: TextStyle(
                                    color: Color(0xFF3D2E15),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}