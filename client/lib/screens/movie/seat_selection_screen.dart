import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/booking_data.dart';
import '../../services/booking_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final BookingData booking;

  const SeatSelectionScreen({super.key, required this.booking});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<SeatSelection> _selectedSeats = [];
  Set<String> _reservedSeats = {};
  bool _isLoading = true;

  final Map<String, double> _tierPrices = {
    'STANDARD': 15.00,
    'PREMIUM': 25.00,
    'GOLD CLASS': 45.00,
  };

@override
void initState() {
  super.initState();
  _loadBookedSeats();
}

Future<void> _loadBookedSeats() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  // Add small delay to ensure DB is updated
  await Future.delayed(const Duration(milliseconds: 300));

  final booked = await BookingService.getBookedSeats(
    movieId: widget.booking.movieId,
    venueName: widget.booking.venueName,
    showDate: widget.booking.showDate,
    showTime: widget.booking.showTime,
    screenNumber: widget.booking.screenNumber ?? 1,
  );

  print('🎫 Booked seats loaded: $booked');

  if (mounted) {
    setState(() {
      _reservedSeats = booked.toSet();
      _isLoading = false;
    });
  }
}

  double get _totalPrice {
    double total = 0;
    for (var seat in _selectedSeats) {
      total += seat.price;
    }
    return total;
  }

  String _getTierForRow(String row) {
    if (['A', 'B'].contains(row)) return 'STANDARD';
    if (['C', 'D', 'E'].contains(row)) return 'PREMIUM';
    return 'GOLD CLASS';
  }

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

  void _toggleSeat(String seatId, String tier, double price) {
    if (_reservedSeats.contains(seatId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seat $seatId is already booked'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() {
      final existing = _selectedSeats.indexWhere((s) => s.id == seatId);
      if (existing != -1) {
        _selectedSeats.removeAt(existing);
      } else {
        _selectedSeats
            .add(SeatSelection(id: seatId, tier: tier, price: price));
      }
    });
  }

  bool _isSelected(String seatId) => _selectedSeats.any((s) => s.id == seatId);

  void _proceedToSummary() {
    if (_selectedSeats.isEmpty) return;

    final updatedBooking = widget.booking.copyWith(
      selectedSeats: _selectedSeats,
    );

    Navigator.pushNamed(
      context,
      RouteNames.bookingSummary,
      arguments: updatedBooking,
    );
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
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const Text(
                    'Select Seats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movie Info with Poster
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (widget.booking.moviePoster.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        widget.booking.moviePoster,
                                        width: 80,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 80,
                                          height: 110,
                                          color: AppColors.primaryLight,
                                          child: const Icon(Icons.movie,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'NOW SHOWING',
                                          style: TextStyle(
                                            color: Color(0xFFC49B63),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.booking.movieTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 12,
                                                color: AppColors.textGrey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                widget.booking.showDate,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textGrey),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 12,
                                                color: AppColors.textGrey),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.booking.showTime,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textGrey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: AppColors.textGrey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                widget.booking.venueName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textDark,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Screen
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.4),
                                    AppColors.primary.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'SCREEN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Legend
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildLegend('Available', Colors.white,
                                    AppColors.borderGrey),
                                _buildLegend('Selected', AppColors.primary,
                                    AppColors.primary),
                                _buildLegend(
                                    'Booked',
                                    const Color(0xFFE5E7EB),
                                    const Color(0xFFE5E7EB)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // STANDARD
                          _buildTierHeader('STANDARD', 15.00, Colors.blueGrey),
                          _buildSeatRow('A', 10),
                          _buildSeatRow('B', 10),
                          const SizedBox(height: 20),

                          // PREMIUM
                          _buildTierHeader(
                              'PREMIUM', 25.00, AppColors.primary),
                          _buildSeatRow('C', 10),
                          _buildSeatRow('D', 10),
                          _buildSeatRow('E', 10),
                          const SizedBox(height: 20),

                          // GOLD CLASS
                          _buildTierHeader(
                              'GOLD CLASS', 45.00, const Color(0xFFC49B63)),
                          _buildSeatRow('F', 8),
                          _buildSeatRow('G', 8),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),

            // Bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedSeats.length} Seats Selected',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (_selectedSeats.isNotEmpty)
                        Flexible(
                          child: Text(
                            _selectedSeats.map((s) => s.id).join(", "),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PRICE',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _selectedSeats.isEmpty ? null : _proceedToSummary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTierHeader(String label, double price, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Horizontal scroll to prevent overflow
  Widget _buildSeatRow(String row, int count) {
    final tier = _getTierForRow(row);
    final price = _tierPrices[tier]!;
    final tierColor = _getTierColor(tier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left row label
            SizedBox(
              width: 20,
              child: Text(
                row,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            // Seats
            ...List.generate(count, (i) {
              final seatId = '$row${i + 1}';
              final isReserved = _reservedSeats.contains(seatId);
              final isSelected = _isSelected(seatId);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => _toggleSeat(seatId, tier, price),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isReserved
                              ? const Color(0xFFE5E7EB)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isReserved
                                ? const Color(0xFFE5E7EB)
                                : tierColor.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isReserved
                                  ? Colors.transparent
                                  : AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Right row label
            SizedBox(
              width: 20,
              child: Text(
                row,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}