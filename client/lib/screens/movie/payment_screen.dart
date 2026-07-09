import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/booking_data.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_snackbar.dart';

class PaymentScreen extends StatefulWidget {
  final BookingData booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _handleStripePayment() async {
    setState(() => _isProcessing = true);

    try {
      // Step 1: Create payment intent on backend
      final intentResponse = await BookingService.createPaymentIntent(
        amount: widget.booking.totalAmount,
      );

      if (intentResponse['success'] != true) {
        throw Exception(
            intentResponse['message'] ?? 'Failed to init payment');
      }

      final clientSecret = intentResponse['clientSecret'];
      final paymentIntentId = intentResponse['paymentIntentId'];

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TicketHub',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColors.primary,
            ),
          ),
        ),
      );

      // Step 3: Show payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment successful - save booking to database
      final confirmResponse = await BookingService.confirmBooking(
        bookingData: widget.booking.toJson(),
        paymentId: paymentIntentId,
      );

      if (!mounted) return;

      if (confirmResponse['success'] == true) {
        final orderNumber =
            confirmResponse['booking']['order_number'] ?? '';
        final movieTitle = widget.booking.movieTitle;

        // ✅ Phone pe popup notification show karo
        await NotificationService.showBookingNotification(
          title: '🎬 Booking Confirmed!',
          message:
              'Your ticket for "$movieTitle" is booked! Order #$orderNumber',
        );

        CustomSnackbar.showSuccess(context, 'Payment successful!');

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.bookingConfirmed,
              (route) => route.settings.name == RouteNames.home,
              arguments: {
                'booking': widget.booking,
                'orderNumber': orderNumber,
              },
            );
          }
        });
      } else {
        throw Exception(
            confirmResponse['message'] ?? 'Failed to save booking');
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        e.error.localizedMessage ?? 'Payment cancelled',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F16),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFFC49B63)),
                    ),
                    const Text(
                      'TicketHub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC49B63),
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Stripe Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF152A20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC49B63)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.credit_card,
                              color: Color(0xFFC49B63), size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pay with Stripe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  'Secure payment via Credit/Debit Card',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _cardLogo('VISA'),
                          _cardLogo('MC'),
                          _cardLogo('AMEX'),
                          _cardLogo('DISC'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (booking.moviePoster.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                booking.moviePoster,
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 60,
                                  height: 90,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.movieTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${booking.venueName}\n${booking.showDate} • ${booking.showTime}',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Seats: ${booking.selectedSeats.join(", ")}',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      _priceRow('Base Ticket Price',
                          '\$${booking.basePrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      _priceRow('Booking Fee (5%)',
                          '\$${booking.bookingFee.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      _priceRow(
                          'Tax (10%)', '\$${booking.tax.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${booking.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFC49B63),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isProcessing ? null : _handleStripePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC49B63),
                            disabledBackgroundColor:
                                const Color(0xFFC49B63)
                                    .withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.lock,
                                        color: Color(0xFF3D2E15),
                                        size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'PAY NOW',
                                      style: TextStyle(
                                        color: Color(0xFF3D2E15),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.shield_outlined,
                                color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'SECURE 256-BIT SSL TRANSACTION',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardLogo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _priceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(amount,
            style:
                const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}