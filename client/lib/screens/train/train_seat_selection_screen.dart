import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../transport/transport_payment_screen.dart';

class TrainSeatSelectionScreen extends StatefulWidget {
  final TransportBooking booking;

  const TrainSeatSelectionScreen({super.key, required this.booking});

  @override
  State<TrainSeatSelectionScreen> createState() =>
      _TrainSeatSelectionScreenState();
}

class _TrainSeatSelectionScreenState extends State<TrainSeatSelectionScreen> {
  Map<String, String> _bookedSeatMap = {};
  final Set<String> _selectedSeats = {};
  bool _isLoading = true;
  int _selectedBogie = 1;

  // Bogies configuration based on class
  Map<String, dynamic> get _bogieConfig {
    final classType = widget.booking.classType?.toLowerCase() ?? '';
    
    if (classType.contains('sleeper')) {
      return {
        'totalBogies': 8,
        'bogiePrefix': 'AS',
        'seatsPerBogie': 24,
        'berthLayout': true, // Lower, Middle, Upper
        'seatsPerRow': 6, // 3 lower + 3 upper (side)
      };
    }
    if (classType.contains('business')) {
      return {
        'totalBogies': 4,
        'bogiePrefix': 'AB',
        'seatsPerBogie': 32,
        'berthLayout': false,
        'seatsPerRow': 4, // 2+2 layout
      };
    }
    if (classType.contains('parlor')) {
      return {
        'totalBogies': 3,
        'bogiePrefix': 'PC',
        'seatsPerBogie': 40,
        'berthLayout': false,
        'seatsPerRow': 4,
      };
    }
    if (classType.contains('standard')) {
      return {
        'totalBogies': 6,
        'bogiePrefix': 'ASC',
        'seatsPerBogie': 48,
        'berthLayout': false,
        'seatsPerRow': 6, // 3+3 layout
      };
    }
    // Economy
    return {
      'totalBogies': 10,
      'bogiePrefix': 'EC',
      'seatsPerBogie': 60,
      'berthLayout': false,
      'seatsPerRow': 6,
    };
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

  String _getBerthType(int seatNum) {
    if (!(_bogieConfig['berthLayout'] as bool)) return '';
    final position = seatNum % 3;
    if (position == 1) return 'LOWER';
    if (position == 2) return 'MIDDLE';
    return 'UPPER';
  }

  Color _getBerthColor(String berth) {
    switch (berth) {
      case 'LOWER': return const Color(0xFF10B981);
      case 'MIDDLE': return const Color(0xFF3B82F6);
      case 'UPPER': return const Color(0xFFF59E0B);
      default: return AppColors.primary;
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
        if (_selectedSeats.length >= _totalPassengers) {
          CustomSnackbar.showError(context, 'Only $_totalPassengers seat(s) allowed');
          return;
        }
        _selectedSeats.add(seatId);
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedSeats.length != _totalPassengers) {
      CustomSnackbar.showError(context, 'Please select $_totalPassengers seat(s)');
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

  @override
  Widget build(BuildContext context) {
    final config = _bogieConfig;
    final totalBogies = config['totalBogies'] as int;

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
                      'Select Your Berth',
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
                          // Train Info
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
                                    child: const Icon(Icons.train, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.booking.operatorName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text(
                                          '${widget.booking.fromLocation} → ${widget.booking.toLocation}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                        ),
                                        Text(
                                          '${widget.booking.classType} • ${totalBogies} Bogies',
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

                          // Bogie selector
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SELECT BOGIE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: totalBogies,
                                      itemBuilder: (context, index) {
                                        final bogieNum = index + 1;
                                        final selected = _selectedBogie == bogieNum;
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedBogie = bogieNum),
                                          child: Container(
                                            width: 60,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: selected ? AppColors.primary : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: selected ? AppColors.primary : Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'B${bogieNum}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: selected ? Colors.white : AppColors.textDark,
                                                    ),
                                                  ),
                                                  Text(
                                                    config['bogiePrefix']!,
                                                    style: TextStyle(
                                                      fontSize: 7,
                                                      color: selected ? Colors.white70 : AppColors.textGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Legend
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                _legend('Available', Colors.white, AppColors.borderGrey),
                                _legend('Selected', AppColors.primary, AppColors.primary),
                                _legend('Booked', Colors.grey.shade400, Colors.grey.shade400),
                                if (config['berthLayout'] as bool) ...[
                                  _legend('Lower', const Color(0xFF10B981), const Color(0xFF10B981)),
                                  _legend('Middle', const Color(0xFF3B82F6), const Color(0xFF3B82F6)),
                                  _legend('Upper', const Color(0xFFF59E0B), const Color(0xFFF59E0B)),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Seats Layout
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGrey),
                            ),
                            child: Column(
                              children: [
                                // Bogie header
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.train, color: AppColors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'BOGIE $_selectedBogie - ${config['bogiePrefix']}$_selectedBogie',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Seats grid
                                if (config['berthLayout'] as bool)
                                  _buildBerthLayout()
                                else
                                  _buildStandardLayout(),

                                const SizedBox(height: 8),
                                const Text(
                                  'END OF BOGIE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGrey,
                                    letterSpacing: 2,
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

            // Bottom
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
                            onPressed: _selectedSeats.length == _totalPassengers
                                ? _proceedToPayment
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
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

  // BERTH LAYOUT (Sleeper)
  Widget _buildBerthLayout() {
    final config = _bogieConfig;
    final seatsPerBogie = config['seatsPerBogie'] as int;
    final prefix = config['bogiePrefix'] as String;
    
    // Berth: 3 seats per compartment (Lower, Middle, Upper)
    // 2 compartments per row (left + right side)
    // So 6 seats per row
    final compartments = seatsPerBogie ~/ 6;

    return Column(
      children: List.generate(compartments, (compIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Compartment label
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Compartment ${compIndex + 1}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left side (Lower, Middle, Upper)
                  Column(
                    children: List.generate(3, (i) {
                      final seatNum = (compIndex * 6) + i + 1;
                      final seatId = '$prefix$_selectedBogie-$seatNum';
                      final berth = i == 0 ? 'LOWER' : i == 1 ? 'MIDDLE' : 'UPPER';
                      return _buildBerthSeat(seatId, berth);
                    }),
                  ),
                  // Aisle
                  Container(
                    width: 30,
                    child: Center(
                      child: Text(
                        '|',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  // Right side
                  Column(
                    children: List.generate(3, (i) {
                      final seatNum = (compIndex * 6) + i + 4;
                      final seatId = '$prefix$_selectedBogie-$seatNum';
                      final berth = i == 0 ? 'LOWER' : i == 1 ? 'MIDDLE' : 'UPPER';
                      return _buildBerthSeat(seatId, berth);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.black12),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBerthSeat(String seatId, String berth) {
    final isBooked = _bookedSeatMap.containsKey(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final berthColor = _getBerthColor(berth);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        onTap: () => _toggleSeat(seatId),
        child: Container(
          width: 90,
          height: 30,
          decoration: BoxDecoration(
            color: isBooked
                ? Colors.grey.shade400
                : isSelected
                    ? berthColor
                    : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isBooked
                  ? Colors.grey.shade400
                  : isSelected
                      ? berthColor
                      : berthColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Berth indicator
              Container(
                width: 20,
                decoration: BoxDecoration(
                  color: isBooked
                      ? Colors.grey.shade600
                      : isSelected
                          ? berthColor.withRed(berthColor.red - 20)
                          : berthColor.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    berth == 'LOWER'
                        ? Icons.chair
                        : berth == 'MIDDLE'
                            ? Icons.airline_seat_flat
                            : Icons.airline_seat_recline_extra,
                    size: 12,
                    color: isBooked || isSelected ? Colors.white : berthColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seatId.split('-')[1],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      berth,
                      style: TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                        color: isBooked
                            ? Colors.white70
                            : isSelected
                                ? Colors.white70
                                : berthColor,
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

  // STANDARD LAYOUT (Non-sleeper)
  Widget _buildStandardLayout() {
    final config = _bogieConfig;
    final seatsPerBogie = config['seatsPerBogie'] as int;
    final seatsPerRow = config['seatsPerRow'] as int;
    final prefix = config['bogiePrefix'] as String;
    final rows = seatsPerBogie ~/ seatsPerRow;
    final halfRow = seatsPerRow ~/ 2;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row number
              SizedBox(
                width: 20,
                child: Text(
                  '${rowIndex + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold),
                ),
              ),
              // Left seats
              ...List.generate(halfRow, (i) {
                final seatNum = (rowIndex * seatsPerRow) + i + 1;
                final seatId = '$prefix$_selectedBogie-$seatNum';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildStandardSeat(seatId),
                );
              }),
              // Aisle
              const SizedBox(width: 20),
              // Right seats
              ...List.generate(halfRow, (i) {
                final seatNum = (rowIndex * seatsPerRow) + halfRow + i + 1;
                final seatId = '$prefix$_selectedBogie-$seatNum';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildStandardSeat(seatId),
                );
              }),
              SizedBox(
                width: 20,
                child: Text(
                  '${rowIndex + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStandardSeat(String seatId) {
    final isBooked = _bookedSeatMap.containsKey(seatId);
    final isSelected = _selectedSeats.contains(seatId);

    return GestureDetector(
      onTap: () => _toggleSeat(seatId),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey.shade400
              : isSelected
                  ? AppColors.primary
                  : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isBooked
                ? Colors.grey.shade400
                : isSelected
                    ? AppColors.primary
                    : AppColors.borderGrey,
            width: 1.2,
          ),
        ),
        child: Center(
          child: isBooked
              ? const Icon(Icons.close, size: 14, color: Colors.white)
              : Text(
                  seatId.split('-')[1],
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