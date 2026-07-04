import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_data.dart';
import '../../../services/booking_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/ticket_save_service.dart';
import '../../../widgets/custom_snackbar.dart';
import 'package:gal/gal.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _userName = 'Guest';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await StorageService.getUser();
    if (user != null) {
      _userName = user['name'] ?? 'Guest';
      _userEmail = user['email'] ?? '';
    }

    final response = await BookingService.getMyBookings();

    if (mounted) {
      setState(() {
        if (response['success'] == true && response['bookings'] != null) {
          _bookings = List<Map<String, dynamic>>.from(response['bookings']);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTicket(Map<String, dynamic> booking) async {
    // Convert booking data to BookingData
    final seats = (booking['seats'] as List)
        .map((s) => SeatSelection(
              id: s.toString(),
              tier: _getTierForSeat(s.toString()),
              price: _getPriceForSeat(s.toString()),
            ))
        .toList();

    final bookingData = BookingData(
      movieId: booking['movie_id'] ?? 0,
      movieTitle: booking['movie_title'] ?? '',
      moviePoster: booking['movie_poster'] ?? '',
      movieBackdrop: '',
      venueName: booking['venue_name'] ?? '',
      venueLocation: booking['venue_location'] ?? '',
      showDate: booking['show_date'] ?? '',
      showTime: booking['show_time'] ?? '',
      screenNumber: booking['screen_number'] ?? 1,
      selectedSeats: seats,
    );

    final success = await TicketSaveService.saveTicketToGallery(
      context: context,
      booking: bookingData,
      orderNumber: booking['order_number'] ?? '',
      userName: _userName,
      userEmail: _userEmail,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(context, '🎫 Ticket saved to Gallery!');
    } else {
      CustomSnackbar.showError(context, 'Failed to save ticket');
    }
  }

  String _getTierForSeat(String seatId) {
    final row = seatId[0];
    if (['A', 'B'].contains(row)) return 'STANDARD';
    if (['C', 'D', 'E'].contains(row)) return 'PREMIUM';
    return 'GOLD CLASS';
  }

  double _getPriceForSeat(String seatId) {
    final tier = _getTierForSeat(seatId);
    switch (tier) {
      case 'STANDARD':
        return 15.00;
      case 'PREMIUM':
        return 25.00;
      case 'GOLD CLASS':
        return 45.00;
      default:
        return 15.00;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'confirmed' || status == null) return AppColors.success;
    if (status == 'cancelled') return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const [
                  Icon(Icons.confirmation_number_outlined,
                      color: AppColors.primary, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _bookings.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(_bookings[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your booking history will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final seats = (booking['seats'] as List?)?.join(", ") ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                if (booking['movie_poster'] != null &&
                    booking['movie_poster'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      booking['movie_poster'],
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 100,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.movie, color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking['movie_title'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking['booking_status'])
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (booking['booking_status'] ?? 'CONFIRMED')
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(booking['booking_status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _iconText(Icons.calendar_today_outlined,
                          booking['show_date'] ?? ''),
                      const SizedBox(height: 4),
                      _iconText(Icons.access_time, booking['show_time'] ?? ''),
                      const SizedBox(height: 4),
                      _iconText(Icons.location_on_outlined,
                          booking['venue_name'] ?? ''),
                      const SizedBox(height: 4),
                      _iconText(Icons.tv, 'Screen ${booking['screen_number'] ?? 1}'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed line
          Row(
            children: List.generate(
              40,
              (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 1,
                  color: i.isEven ? AppColors.borderGrey : Colors.transparent,
                ),
              ),
            ),
          ),

          // Bottom section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_seat, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Seats: $seats',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${booking['order_number'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${double.parse(booking['total_amount']?.toString() ?? '0').toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _saveTicket(booking),
                      icon: const Icon(Icons.download, size: 16, color: Colors.white),
                      label: const Text(
                        'Save Ticket',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }
}