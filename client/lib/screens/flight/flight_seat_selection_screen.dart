import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../transport/transport_payment_screen.dart';

class FlightSeatSelectionScreen extends StatefulWidget {
  final TransportBooking booking;

  const FlightSeatSelectionScreen({super.key, required this.booking});

  @override
  State<FlightSeatSelectionScreen> createState() =>
      _FlightSeatSelectionScreenState();
}

class _FlightSeatSelectionScreenState extends State<FlightSeatSelectionScreen> {
  Map<String, String> _bookedSeatMap = {};
  final Set<String> _selectedSeats = {};
  bool _isLoading = true;

  final List<String> _seatLetters = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int _totalRows = 30;

  final int _firstClassRows = 3;
  final int _businessRows = 6;

  // User's selected class
  String get _selectedClass => widget.booking.classType ?? 'ECONOMY';

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
  }

  Future<void> _loadBookedSeats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final result = await TransportService.getBookedSeats(
      operatorNumber: widget.booking.operatorNumber,
      departureDate: widget.booking.departureDate,
      departureTime: widget.booking.departureTime,
    );

    if (mounted) {
      setState(() {
        _bookedSeatMap = Map<String, String>.from(result['seatMap'] ?? {});
        _isLoading = false;
      });
    }
  }

  int get _totalPassengers => widget.booking.passengers.length;

  String _getSeatClass(int row) {
    if (row <= _firstClassRows) return 'FIRST CLASS';
    if (row <= _firstClassRows + _businessRows) return 'BUSINESS';
    return 'ECONOMY';
  }

  Color _getSeatClassColor(int row) {
    if (row <= _firstClassRows) return const Color(0xFFC49B63);
    if (row <= _firstClassRows + _businessRows) return const Color(0xFF7B61FF);
    return AppColors.primary;
  }

  // ✅ Check if row matches user's selected class
  bool _isRowInSelectedClass(int row) {
    final rowClass = _getSeatClass(row);
    // Normalize both strings for comparison
    final userClass = _selectedClass.toUpperCase().trim();
    
    if (userClass.contains('FIRST')) return rowClass == 'FIRST CLASS';
    if (userClass.contains('BUSINESS')) return rowClass == 'BUSINESS';
    if (userClass.contains('ECONOMY')) return rowClass == 'ECONOMY';
    return true;
  }

  void _toggleSeat(String seatId, int row) {
    // Check if seat is booked
    if (_bookedSeatMap.containsKey(seatId)) {
      CustomSnackbar.showError(context, 'Seat $seatId is already booked');
      return;
    }

    // ✅ Check if seat belongs to user's selected class
    if (!_isRowInSelectedClass(row)) {
      final rowClass = _getSeatClass(row);
      CustomSnackbar.showError(
        context,
        'You booked $_selectedClass class. Please select seats in $_selectedClass section only!',
      );
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        if (_selectedSeats.length >= _totalPassengers) {
          CustomSnackbar.showError(
              context, 'Only $_totalPassengers seat(s) allowed');
          return;
        }
        _selectedSeats.add(seatId);
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedSeats.length != _totalPassengers) {
      CustomSnackbar.showError(
          context, 'Please select $_totalPassengers seat(s)');
      return;
    }

    final genderMap = <String, String>{};
    final seatList = _selectedSeats.toList();
    for (var i = 0; i < seatList.length; i++) {
      if (i < widget.booking.passengers.length) {
        genderMap[seatList[i]] = widget.booking.passengers[i].gender;
      }
    }

    final updated = widget.booking.copyWith(
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

  Color _getSeatColor(String seatId, int row) {
    // Booked
    if (_bookedSeatMap.containsKey(seatId)) {
      return Colors.grey.shade400;
    }
    // Selected
    if (_selectedSeats.contains(seatId)) {
      return _getSeatClassColor(row);
    }
    // Not in user's class - disabled look
    if (!_isRowInSelectedClass(row)) {
      return Colors.grey.shade100;
    }
    // Available in user's class
    return Colors.white;
  }

  Color _getSeatBorderColor(String seatId, int row) {
    if (_bookedSeatMap.containsKey(seatId)) {
      return Colors.grey.shade400;
    }
    if (_selectedSeats.contains(seatId)) {
      return _getSeatClassColor(row);
    }
    if (!_isRowInSelectedClass(row)) {
      return Colors.grey.shade300;
    }
    return _getSeatClassColor(row).withValues(alpha: 0.4);
  }

  @override
  Widget build(BuildContext context) {
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
                          // Flight Info
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.flight,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.booking.operatorName,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          '${widget.booking.fromLocation} → ${widget.booking.toLocation}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey),
                                        ),
                                        Text(
                                          '${widget.booking.departureDate} • ${widget.booking.departureTime}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ✅ CLASS INFO BANNER
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getUserClassColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _getUserClassColor(),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.airline_seat_recline_extra,
                                  color: _getUserClassColor(),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You booked ${_selectedClass.toUpperCase()} class',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _getUserClassColor(),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Only select seats in the ${_selectedClass.toUpperCase()} section',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Legend
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _legend('Available', Colors.white, _getUserClassColor()),
                                _legend('Selected', _getUserClassColor(), _getUserClassColor()),
                                _legend('Booked', Colors.grey.shade400, Colors.grey.shade400),
                                _legend('Other Class', Colors.grey.shade100, Colors.grey.shade300),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Airplane Layout
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              children: [
                                // Cockpit
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(60),
                                      topRight: Radius.circular(60),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'COCKPIT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textGrey,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 20),
                                    ..._seatLetters.map((l) => Container(
                                          width: 28,
                                          alignment: Alignment.center,
                                          child: Text(l,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textGrey)),
                                        )),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                ...List.generate(_totalRows, (index) {
                                  final row = index + 1;
                                  final showDivider = row == _firstClassRows + 1 ||
                                      row == _firstClassRows + _businessRows + 1;

                                  return Column(
                                    children: [
                                      if (showDivider)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 1,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  _getSeatClass(row),
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getSeatClassColor(row),
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 1,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      _buildRow(row),
                                    ],
                                  );
                                }),

                                const SizedBox(height: 10),
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(40),
                                      bottomRight: Radius.circular(40),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'TAIL',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textGrey,
                                        letterSpacing: 2,
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

            // Bottom bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${_selectedSeats.length}/$_totalPassengers',
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
                              style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                          Text(
                            'PKR ${widget.booking.totalAmount.toStringAsFixed(0)}',
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
                            onPressed: _selectedSeats.length == _totalPassengers
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

  // Get color based on user's selected class
  Color _getUserClassColor() {
    final upper = _selectedClass.toUpperCase();
    if (upper.contains('FIRST')) return const Color(0xFFC49B63);
    if (upper.contains('BUSINESS')) return const Color(0xFF7B61FF);
    return AppColors.primary;
  }

  Widget _legend(String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  Widget _buildRow(int rowNum) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            child: Text('$rowNum',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold)),
          ),
          _buildSeat('${rowNum}A', rowNum),
          const SizedBox(width: 3),
          _buildSeat('${rowNum}B', rowNum),
          const SizedBox(width: 3),
          _buildSeat('${rowNum}C', rowNum),
          const SizedBox(width: 12),
          _buildSeat('${rowNum}D', rowNum),
          const SizedBox(width: 3),
          _buildSeat('${rowNum}E', rowNum),
          const SizedBox(width: 3),
          _buildSeat('${rowNum}F', rowNum),
          SizedBox(
            width: 20,
            child: Text('$rowNum',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(String seatId, int row) {
    final isBooked = _bookedSeatMap.containsKey(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final isMyClass = _isRowInSelectedClass(row);
    final classColor = _getSeatClassColor(row);

    return GestureDetector(
      onTap: () => _toggleSeat(seatId, row),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _getSeatColor(seatId, row),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _getSeatBorderColor(seatId, row),
            width: 1.2,
          ),
        ),
        child: Center(
          child: isBooked
              ? const Icon(Icons.close, size: 12, color: Colors.white)
              : !isMyClass
                  ? Icon(Icons.lock, size: 10, color: Colors.grey.shade400)
                  : Text(
                      seatId.substring(seatId.length - 1),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : classColor,
                      ),
                    ),
        ),
      ),
    );
  }
}