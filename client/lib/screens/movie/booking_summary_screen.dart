import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/booking_data.dart';

class BookingSummaryScreen extends StatelessWidget {
  final BookingData booking;

  const BookingSummaryScreen({super.key, required this.booking});

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'STANDARD':
        return Colors.blueGrey;
      case 'PREMIUM':
        return AppColors.primary;
      case 'GOLD CLASS':
        return const Color(0xFFC49B63);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    if (booking.moviePoster.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            booking.moviePoster,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 240,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Movie Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NOW SHOWING',
                              style: TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking.movieTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoBox(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'DATE',
                                  value: booking.showDate,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoBox(
                                  icon: Icons.access_time,
                                  label: 'TIME',
                                  value: booking.showTime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Venue & Seats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.local_movies),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child:Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      booking.venueName,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      booking.venueLocation,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textGrey,
      ),
    ),
    // ADD SCREEN NUMBER
    const SizedBox(height: 4),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'SCREEN ${booking.screenNumber ?? 1}',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    ),
  ],
),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Seats with tier colors
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: booking.selectedSeats.map((s) {
                              final color = _getTierColor(s.tier);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_seat, size: 11, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${s.id} • \$${s.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.receipt_long, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ============================
                          // INDIVIDUAL SEATS WITH PRICES
                          // ============================
                          ...booking.selectedSeats.map((s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildPriceRow(
                                '${s.id} (${s.tier})',
                                '\$${s.price.toStringAsFixed(2)}',
                              ),
                            );
                          }),

                          const Divider(),
                          const SizedBox(height: 8),

                          // Subtotal
                          _buildPriceRow(
                            'Subtotal',
                            '\$${booking.basePrice.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 10),
                          _buildPriceRow(
                            'Booking Fee (5%)',
                            '\$${booking.bookingFee.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 10),
                          _buildPriceRow(
                            'Tax (10%)',
                            '\$${booking.tax.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'TOTAL PAYABLE',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${booking.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Payment Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                RouteNames.payment,
                                arguments: booking,
                              ),
                              icon: const Icon(Icons.lock_outline,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'PROCEED TO PAYMENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Text(amount,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}