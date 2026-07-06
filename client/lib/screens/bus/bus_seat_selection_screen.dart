import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../transport/transport_payment_screen.dart';

class BusSeatSelectionScreen extends StatefulWidget {
  final TransportBooking booking;

  const BusSeatSelectionScreen({super.key, required this.booking});

  @override
  State<BusSeatSelectionScreen> createState() => _BusSeatSelectionScreenState();
}

class _BusSeatSelectionScreenState extends State<BusSeatSelectionScreen> {
  Map<String, String> _bookedSeatMap = {};
  List<String> _bookedCNICs = [];
  final Map<String, String> _selectedSeatMap = {};
  int _currentPassengerIndex = 0;
  bool _isLoading = true;

  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
  }

  Future<void> _loadBookedSeats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _bookedSeatMap = {};
      _bookedCNICs = [];
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final result = await TransportService.getBookedSeats(
      operatorNumber: widget.booking.operatorNumber,
      departureDate: widget.booking.departureDate,
      departureTime: widget.booking.departureTime,
    );

    print('🎫 Booked seats: ${result['seatMap']}');
    print('👥 Booked CNICs: ${result['bookedCNICs']}');

    // Check if any current passenger already booked
    final passengerCNICs = widget.booking.passengers
        .map((p) => p.idNumber.replaceAll('-', ''))
        .toList();

    final alreadyBookedPassengers = <String>[];
    for (var i = 0; i < passengerCNICs.length; i++) {
      if ((result['bookedCNICs'] as List).contains(passengerCNICs[i])) {
        alreadyBookedPassengers.add(widget.booking.passengers[i].fullName);
      }
    }

    if (mounted) {
      setState(() {
        _bookedSeatMap = Map<String, String>.from(result['seatMap'] ?? {});
        _bookedCNICs = List<String>.from(result['bookedCNICs'] ?? []);
        _isLoading = false;
      });

      // Show warning if passenger already booked
      if (alreadyBookedPassengers.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showAlreadyBookedDialog(alreadyBookedPassengers);
          }
        });
      }
    }
  }

  void _showAlreadyBookedDialog(List<String> passengerNames) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Passenger Already Booked!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The following passenger(s) have already booked seats on this bus:',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),
            ...passengerNames.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 10),
            const Text(
              'One passenger can only book ONE seat per bus. Please go back and remove duplicate passenger.',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  int get _totalPassengers => widget.booking.passengers.length;
  String get _currentPassengerGender =>
      widget.booking.passengers[_currentPassengerIndex].gender;

  bool _canSelectSeat(String seatId) {
    if (_bookedSeatMap.containsKey(seatId)) return false;
    if (_selectedSeatMap.containsKey(seatId)) return true;

    final adjacentSeats = _getAdjacentSeats(seatId);
    for (var adjSeat in adjacentSeats) {
      final adjGender = _bookedSeatMap[adjSeat] ?? _selectedSeatMap[adjSeat];
      if (adjGender != null && adjGender != _currentPassengerGender) {
        return false;
      }
    }

    return true;
  }

  List<String> _getAdjacentSeats(String seatId) {
    if (seatId.startsWith('BACK')) return [];

    final row = seatId[0];
    final num = int.tryParse(seatId.substring(1)) ?? 0;

    final adjacent = <String>[];
    if (num == 1) adjacent.add('${row}2');
    if (num == 2) adjacent.add('${row}1');
    if (num == 3) adjacent.add('${row}4');
    if (num == 4) adjacent.add('${row}3');

    return adjacent;
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeatMap.containsKey(seatId)) {
      CustomSnackbar.showError(context, 'Seat $seatId is already booked');
      return;
    }

    setState(() {
      if (_selectedSeatMap.containsKey(seatId)) {
        _selectedSeatMap.remove(seatId);
        _currentPassengerIndex = _selectedSeatMap.length;
      } else {
        if (_selectedSeatMap.length >= _totalPassengers) {
          CustomSnackbar.showError(context, 'You can only select $_totalPassengers seat(s)');
          return;
        }

        final hasConflict = !_canSelectSeat(seatId);

        if (hasConflict) {
          _showGenderWarningDialog(seatId);
        } else {
          _selectedSeatMap[seatId] = _currentPassengerGender;
          if (_currentPassengerIndex < _totalPassengers - 1) {
            _currentPassengerIndex++;
          }
        }
      }
    });
  }

  void _showGenderWarningDialog(String seatId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 10),
            Text('Gender Notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The adjacent seat is booked by a passenger of different gender.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 10),
            Text(
              'Male and Female should not sit adjacent unless family.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
            ),
            SizedBox(height: 10),
            Text(
              'Are you traveling as family?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedSeatMap[seatId] = _currentPassengerGender;
                if (_currentPassengerIndex < _totalPassengers - 1) {
                  _currentPassengerIndex++;
                }
              });
              CustomSnackbar.showSuccess(context, 'Seat $seatId booked!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Book Anyway',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    if (_selectedSeatMap.length != _totalPassengers) {
      CustomSnackbar.showError(context, 'Please select $_totalPassengers seat(s)');
      return;
    }

    final updated = widget.booking.copyWith(
      seatNumbers: _selectedSeatMap.keys.toList(),
      seatGenderMap: Map<String, String>.from(_selectedSeatMap),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransportPaymentScreen(booking: updated),
      ),
    );
  }

  Color _getSeatColor(String seatId) {
    if (_bookedSeatMap.containsKey(seatId)) {
      final gender = _bookedSeatMap[seatId];
      return gender == 'Female'
          ? const Color(0xFFEC407A).withValues(alpha: 0.4)
          : const Color(0xFF42A5F5).withValues(alpha: 0.4);
    }
    if (_selectedSeatMap.containsKey(seatId)) {
      final gender = _selectedSeatMap[seatId];
      return gender == 'Female' ? const Color(0xFFEC407A) : AppColors.primary;
    }
    return Colors.white;
  }

  Color _getSeatBorderColor(String seatId) {
    if (_bookedSeatMap.containsKey(seatId)) {
      return Colors.grey.shade400;
    }
    if (_selectedSeatMap.containsKey(seatId)) {
      final gender = _selectedSeatMap[seatId];
      return gender == 'Female' ? const Color(0xFFEC407A) : AppColors.primary;
    }
    return AppColors.borderGrey;
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
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
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
                                    child: const Icon(Icons.directions_bus,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.booking.operatorName,
                                            style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text(
                                          '${widget.booking.fromLocation} → ${widget.booking.toLocation}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                        ),
                                        Text(
                                          '${widget.booking.departureDate} • ${widget.booking.departureTime}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_selectedSeatMap.length < _totalPassengers)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _currentPassengerGender == 'Female'
                                    ? const Color(0xFFEC407A).withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _currentPassengerGender == 'Female'
                                      ? const Color(0xFFEC407A)
                                      : AppColors.primary,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _currentPassengerGender == 'Female'
                                        ? Icons.female
                                        : Icons.male,
                                    color: _currentPassengerGender == 'Female'
                                        ? const Color(0xFFEC407A)
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Select seat for Passenger ${_currentPassengerIndex + 1} ($_currentPassengerGender)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _currentPassengerGender == 'Female'
                                            ? const Color(0xFFEC407A)
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _legend('Available', Colors.white, AppColors.borderGrey),
                                _legend('Male Selected', AppColors.primary, AppColors.primary),
                                _legend('Female Selected', const Color(0xFFEC407A), const Color(0xFFEC407A)),
                                _legend('Booked', const Color(0xFF42A5F5).withValues(alpha: 0.4),
                                    Colors.grey.shade400),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.person, size: 20, color: AppColors.textGrey),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('DRIVER',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textGrey,
                                            letterSpacing: 1)),
                                    const Spacer(),
                                    const Icon(Icons.stairs, size: 18, color: AppColors.textGrey),
                                    const Text('  ENTRY',
                                        style: TextStyle(fontSize: 9, color: AppColors.textGrey)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),

                                Column(
                                  children: _rows.map((row) => _buildSeatRow(row)).toList(),
                                ),

                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(5, (i) {
                                    final seatId = 'BACK${i + 1}';
                                    return _buildSeat(seatId);
                                  }),
                                ),
                                const SizedBox(height: 6),
                                const Text('BACK ROW',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textGrey,
                                        letterSpacing: 1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
              ),
              child: Column(
                children: [
                  if (_selectedSeatMap.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected: ${_selectedSeatMap.keys.join(", ")}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${_selectedSeatMap.length}/$_totalPassengers',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                            onPressed: _selectedSeatMap.length == _totalPassengers
                                ? _proceedToPayment
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Proceed to Payment',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

  Widget _buildSeatRow(String row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(row,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold)),
          ),
          _buildSeat('${row}1'),
          const SizedBox(width: 4),
          _buildSeat('${row}2'),
          const Spacer(),
          const Icon(Icons.stairs, size: 12, color: AppColors.textGrey),
          const Spacer(),
          _buildSeat('${row}3'),
          const SizedBox(width: 4),
          _buildSeat('${row}4'),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildSeat(String seatId) {
    final isBooked = _bookedSeatMap.containsKey(seatId);
    final isSelected = _selectedSeatMap.containsKey(seatId);

    return GestureDetector(
      onTap: () => _toggleSeat(seatId),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _getSeatColor(seatId),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _getSeatBorderColor(seatId), width: 1.5),
        ),
        child: Center(
          child: isBooked
              ? Icon(
                  _bookedSeatMap[seatId] == 'Female' ? Icons.female : Icons.male,
                  size: 14,
                  color: Colors.grey.shade600,
                )
              : Text(
                  seatId.startsWith('BACK') ? seatId.substring(4) : seatId,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
        ),
      ),
    );
  }
}