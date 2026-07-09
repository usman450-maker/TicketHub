import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../transport/transport_payment_screen.dart';

class SportsSeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> match;
  final Map<String, dynamic> category;
  final int ticketCount;
  final double totalPrice;
  final TransportBooking? booking;

  const SportsSeatSelectionScreen({
    super.key,
    required this.match,
    required this.category,
    required this.ticketCount,
    required this.totalPrice,
    this.booking,
  });

  @override
  State<SportsSeatSelectionScreen> createState() =>
      _SportsSeatSelectionScreenState();
}

class _SportsSeatSelectionScreenState extends State<SportsSeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  Map<String, String> _bookedSeatMap = {};
  bool _isLoading = true;

  final List<String> _sections = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  Color get _categoryColor {
    try {
      return Color(int.parse('0xFF${widget.category['color']}'));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
  }

  Future<void> _loadBookedSeats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (widget.booking != null &&
        widget.booking!.operatorNumber.isNotEmpty) {
      final result = await TransportService.getBookedSeats(
        operatorNumber: widget.booking!.operatorNumber,
        departureDate: widget.booking!.departureDate,
        departureTime: widget.booking!.departureTime,
      );

      if (mounted) {
        setState(() {
          _bookedSeatMap = Map<String, String>.from(result['seatMap'] ?? {});
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _bookedSeatMap = {};
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeatMap.containsKey(seatId)) {
      CustomSnackbar.showError(context, 'Seat $seatId is already booked');
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length >= widget.ticketCount) {
          CustomSnackbar.showError(
              context, 'Only ${widget.ticketCount} seat(s) allowed');
          return;
        }
        _selectedSeats.add(seatId);
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedSeats.length != widget.ticketCount) {
      CustomSnackbar.showError(
          context, 'Please select ${widget.ticketCount} seat(s)');
      return;
    }

    if (widget.booking == null) return;

    final genderMap = <String, String>{};
    final seatList = _selectedSeats.toList();
    for (var i = 0; i < seatList.length; i++) {
      if (i < widget.booking!.passengers.length) {
        genderMap[seatList[i]] = widget.booking!.passengers[i].gender;
      }
    }

    final updated = widget.booking!.copyWith(
      seatNumbers: seatList,
      seatGenderMap: genderMap,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransportPaymentScreen(booking: updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final operatorName = widget.booking?.operatorName ?? 'Match';
    final venue = widget.booking?.fromLocation ?? '';
    final date = widget.booking?.departureDate ?? '';
    final classType = widget.booking?.classType ?? widget.category['name'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  const Expanded(
                    child: Text(
                      'Select Your Seats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      child: Column(
                        children: [

                          // Stadium Banner
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    height: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.isNotEmpty ? venue : 'Stadium',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$operatorName • $date',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
const SizedBox(height: 16),
                          // Match Info
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _categoryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.stadium,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          operatorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (venue.isNotEmpty)
                                          Text(
                                            '$venue • $date',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textGrey),
                                          ),
                                        if (classType.isNotEmpty)
                                          Text(
                                            classType,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _categoryColor),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Legend
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                _legend('Available', Colors.white,
                                    _categoryColor),
                                _legend('Selected', _categoryColor,
                                    _categoryColor),
                                _legend('Booked', Colors.grey.shade400,
                                    Colors.grey.shade400),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stadium View
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              children: [
                                // Field
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 60),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.green.shade800,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.sports,
                                          color: Colors.white, size: 24),
                                      SizedBox(height: 4),
                                      Text(
                                        'PLAYING FIELD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Sections
                                ...List.generate(_sections.length,
                                    (sectionIndex) {
                                  return _buildSection(
                                      _sections[sectionIndex]);
                                }),
                              ],
                            ),
                          ),
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
                border:
                    Border(top: BorderSide(color: AppColors.borderGrey)),
              ),
              child: Column(
                children: [
                  if (_selectedSeats.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Selected: ${_selectedSeats.join(", ")}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _categoryColor,
                            ),
                          ),
                        ),
                        Text(
                          '${_selectedSeats.length}/${widget.ticketCount}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGrey)),
                          Text(
                            'PKR ${widget.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _selectedSeats.length == widget.ticketCount
                                    ? _proceedToPayment
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _legend(String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildSection(String section) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Section $section',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _categoryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (i) {
              final seatId = '$section${i + 1}';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildSeat(seatId),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(String seatId) {
    final isBooked = _bookedSeatMap.containsKey(seatId);
    final isSelected = _selectedSeats.contains(seatId);

    return GestureDetector(
      onTap: () => _toggleSeat(seatId),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey.shade400
              : isSelected
                  ? _categoryColor
                  : Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isBooked
                ? Colors.grey.shade400
                : isSelected
                    ? _categoryColor
                    : _categoryColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Center(
          child: isBooked
              ? const Icon(Icons.close, size: 10, color: Colors.white)
              : Text(
                  seatId.substring(1),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : _categoryColor,
                  ),
                ),
        ),
      ),
    );
  }
}