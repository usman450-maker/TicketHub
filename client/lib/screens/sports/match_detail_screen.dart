import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/sports_data.dart';
import '../../models/transport_booking.dart';
import '../../services/transport_service.dart';
import '../transport/passenger_details_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  int _selectedCategory = -1;
  int _ticketCount = 1;
  int _availableSeats = 0;
  bool _isLoadingSeats = true;

  // Total stadium seats (8 sections x 10 seats = 80)
  final int _totalStadiumSeats = 80;

  @override
  void initState() {
    super.initState();
    _availableSeats = widget.match['seatsLeft'] as int;
    _loadBookedSeatsCount();
  }

  Future<void> _loadBookedSeatsCount() async {
    setState(() => _isLoadingSeats = true);

    try {
      final result = await TransportService.getBookedSeats(
        operatorNumber: 'MATCH-${widget.match['id']}',
        departureDate: widget.match['date'],
        departureTime: widget.match['time'],
      );

      final bookedCount = (result['seatMap'] as Map?)?.length ?? 0;
      
      if (mounted) {
        setState(() {
          _availableSeats = _totalStadiumSeats - bookedCount;
          if (_availableSeats < 0) _availableSeats = 0;
          _isLoadingSeats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSeats = widget.match['seatsLeft'] as int;
          _isLoadingSeats = false;
        });
      }
    }
  }

  double get _selectedPrice {
    if (_selectedCategory == -1) return 0;
    final cat = SportsData.seatCategories[_selectedCategory];
    return (widget.match['basePrice'] as double) *
        (cat['multiplier'] as double);
  }

  double get _totalPrice => _selectedPrice * _ticketCount;

  void _proceedToNext() {
    if (_selectedCategory == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ticket category')),
      );
      return;
    }

    if (_ticketCount > _availableSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Only $_availableSeats seats available')),
      );
      return;
    }

    final cat = SportsData.seatCategories[_selectedCategory];

    final passengers = List.generate(
      _ticketCount,
      (i) => Passenger(
        fullName: '',
        idNumber: '',
        gender: 'Male',
        age: 0,
        nationality: '',
        email: '',
        phone: '',
      ),
    );

    final booking = TransportBooking(
      transportType: 'sports',
      operatorName: '${widget.match['team1']} vs ${widget.match['team2']}',
      operatorNumber: 'MATCH-${widget.match['id']}',
      fromLocation: widget.match['venue'],
      toLocation: widget.match['city'],
      departureDate: widget.match['date'],
      departureTime: widget.match['time'],
      classType: cat['name'],
      pricePerPassenger: _selectedPrice,
      passengers: passengers,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PassengerDetailsScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(m['image']),
                              fit: BoxFit.cover,
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
                                  Colors.black.withValues(alpha: 0.5),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: AppColors.primary, size: 20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _tag(m['league'], const Color(0xFFC49B63)),
                                  const SizedBox(width: 6),
                                  _tag(m['sport'],
                                      Colors.white.withValues(alpha: 0.2)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${m['team1']} vs ${m['team2']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Match Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _teamInfo(m['team1'],
                                        m['team1Short'], AppColors.primary)),
                                Column(
                                  children: [
                                    Text(
                                      m['time'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Text(
                                      'VS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                    child: _teamInfo(
                                        m['team2'],
                                        m['team2Short'],
                                        const Color(0xFFC49B63))),
                              ],
                            ),
                            const Divider(height: 24),
                            _infoRow(Icons.calendar_today, 'Date', m['date']),
                            const SizedBox(height: 8),
                            _infoRow(Icons.location_on, 'Venue',
                                '${m['venue']}, ${m['city']}'),
                            const SizedBox(height: 8),

                            // LIVE Available seats
                            Row(
                              children: [
                                const Icon(Icons.event_seat,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 90,
                                  child: Text('Available',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textGrey)),
                                ),
                                Expanded(
                                  child: _isLoadingSeats
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              '$_availableSeats seats',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _availableSeats < 10
                                                    ? const Color(0xFFFEE2E2)
                                                    : _availableSeats < 30
                                                        ? const Color(
                                                            0xFFFEF3C7)
                                                        : const Color(
                                                            0xFFE8F5E9),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _availableSeats < 10
                                                    ? 'Almost Full!'
                                                    : _availableSeats < 30
                                                        ? 'Filling Fast'
                                                        : 'Available',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: _availableSeats < 10
                                                      ? const Color(
                                                          0xFFB91C1C)
                                                      : _availableSeats < 30
                                                          ? const Color(
                                                              0xFF92400E)
                                                          : const Color(
                                                              0xFF065F46),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ticket Categories
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Select Ticket Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...SportsData.seatCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cat = entry.value;
                      final price = (m['basePrice'] as double) *
                          (cat['multiplier'] as double);
                      final selected = _selectedCategory == index;
                      final color =
                          Color(int.parse('0xFF${cat['color']}'));

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : AppColors.borderGrey,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat['code'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        cat['description'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'PKR ${price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    if (selected)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Icon(Icons.check_circle,
                                            color: AppColors.primary,
                                            size: 18),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Ticket count
                    if (_selectedCategory != -1)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Number of Tickets',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (_ticketCount > 1) {
                                        setState(() => _ticketCount--);
                                      }
                                    },
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: AppColors.primary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$_ticketCount',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (_ticketCount < 10 &&
                                          _ticketCount < _availableSeats) {
                                        setState(() => _ticketCount++);
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle,
                                        color: AppColors.primary),
                                  ),
                                ],
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

            // Bottom
            if (_selectedCategory != -1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: AppColors.borderGrey)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey)),
                        Text(
                          'PKR ${_totalPrice.toStringAsFixed(0)}',
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
                          onPressed: _availableSeats > 0
                              ? _proceedToNext
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _availableSeats > 0
                                ? 'Continue to Person Details'
                                : 'SOLD OUT',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _teamInfo(String name, String code, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}