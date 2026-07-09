import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../transport/passenger_details_screen.dart';

class FlightListScreen extends StatefulWidget {
  final Map<String, String> fromAirport;
  final Map<String, String> toAirport;
  final String date;
  final int passengers;
  final String classType;

  const FlightListScreen({
    super.key,
    required this.fromAirport,
    required this.toAirport,
    required this.date,
    required this.passengers,
    required this.classType,
  });

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  String _sortBy = 'Cheapest First';

  double get _priceMultiplier {
    if (widget.classType == 'Business') return 2.5;
    if (widget.classType == 'First Class') return 4.0;
    return 1.0;
  }

  List<Map<String, dynamic>> get _flights {
    final base = [
      {
        'airline': 'PIA',
        'code': 'PK-301',
        'aircraft': 'Boeing 777',
        'rating': 4.5,
        'reviews': '3.2k',
        'departure': '08:00',
        'arrival': '10:30',
        'duration': '2h 30m',
        'stops': 'NON-STOP',
        'basePrice': 45000.00,
        'terminal': 'T1',
        'baggage': '30kg',
      },
      {
        'airline': 'Emirates',
        'code': 'EK-624',
        'aircraft': 'Airbus A380',
        'rating': 4.9,
        'reviews': '15k',
        'departure': '10:30',
        'arrival': '13:00',
        'duration': '2h 30m',
        'stops': 'NON-STOP',
        'basePrice': 65000.00,
        'terminal': 'T3',
        'baggage': '35kg',
        'premium': true,
      },
      {
        'airline': 'Qatar Airways',
        'code': 'QR-627',
        'aircraft': 'Boeing 787',
        'rating': 4.8,
        'reviews': '12k',
        'departure': '14:00',
        'arrival': '17:15',
        'duration': '3h 15m',
        'stops': '1 STOP (DOH)',
        'basePrice': 55000.00,
        'terminal': 'T2',
        'baggage': '30kg',
      },
      {
        'airline': 'Turkish Airlines',
        'code': 'TK-712',
        'aircraft': 'Airbus A330',
        'rating': 4.7,
        'reviews': '8.5k',
        'departure': '16:30',
        'arrival': '20:00',
        'duration': '3h 30m',
        'stops': '1 STOP (IST)',
        'basePrice': 52000.00,
        'terminal': 'T1',
        'baggage': '30kg',
      },
      {
        'airline': 'AirBlue',
        'code': 'PA-431',
        'aircraft': 'Airbus A320',
        'rating': 4.2,
        'reviews': '1.5k',
        'departure': '18:45',
        'arrival': '21:15',
        'duration': '2h 30m',
        'stops': 'NON-STOP',
        'basePrice': 38000.00,
        'terminal': 'T1',
        'baggage': '25kg',
      },
      {
        'airline': 'Etihad Airways',
        'code': 'EY-243',
        'aircraft': 'Boeing 777',
        'rating': 4.6,
        'reviews': '9k',
        'departure': '22:00',
        'arrival': '00:30',
        'duration': '2h 30m',
        'stops': 'NON-STOP',
        'basePrice': 58000.00,
        'terminal': 'T3',
        'baggage': '32kg',
      },
      {
        'airline': 'SereneAir',
        'code': 'ER-503',
        'aircraft': 'ATR 72',
        'rating': 4.3,
        'reviews': '900',
        'departure': '06:30',
        'arrival': '09:00',
        'duration': '2h 30m',
        'stops': 'NON-STOP',
        'basePrice': 35000.00,
        'terminal': 'T2',
        'baggage': '25kg',
      },
      {
        'airline': 'Saudia',
        'code': 'SV-703',
        'aircraft': 'Boeing 787',
        'rating': 4.5,
        'reviews': '6.5k',
        'departure': '11:45',
        'arrival': '15:30',
        'duration': '3h 45m',
        'stops': '1 STOP (JED)',
        'basePrice': 48000.00,
        'terminal': 'T2',
        'baggage': '30kg',
      },
    ];

    // Apply class multiplier
    return base.map((f) => {
      ...f,
      'price': (f['basePrice'] as double) * _priceMultiplier,
    }).toList();
  }

  List<Map<String, dynamic>> get _sortedFlights {
    final list = List<Map<String, dynamic>>.from(_flights);
    switch (_sortBy) {
      case 'Cheapest First':
        list.sort((a, b) => (a['price'] as double).compareTo(b['price']));
        break;
      case 'Highest Rated':
        list.sort((a, b) => (b['rating'] as double).compareTo(a['rating']));
        break;
      case 'Departure Time':
        list.sort((a, b) => (a['departure'] as String).compareTo(b['departure']));
        break;
      case 'Duration':
        list.sort((a, b) => (a['duration'] as String).compareTo(b['duration']));
        break;
    }
    return list;
  }

  void _selectFlight(Map<String, dynamic> flight) {
    // Create passengers list based on count
    final passengers = List.generate(widget.passengers, (i) => Passenger(
      fullName: '',
      idNumber: '',
      gender: 'Male',
      age: 0,
      nationality: '',
      email: '',
      phone: '',
    ));

    final booking = TransportBooking(
      transportType: 'flight',
      operatorName: flight['airline'],
      operatorNumber: flight['code'],
      fromLocation: '${widget.fromAirport['city']} (${widget.fromAirport['code']})',
      toLocation: '${widget.toAirport['city']} (${widget.toAirport['code']})',
      departureDate: widget.date,
      departureTime: flight['departure'],
      arrivalTime: flight['arrival'],
      duration: flight['duration'],
      classType: widget.classType.toUpperCase(),
      pricePerPassenger: flight['price'],
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const Text(
                    'TicketHub',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Route header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.fromAirport['code']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.fromAirport['city']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.flight, color: Colors.white),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.toAirport['code']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.toAirport['city']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _headerItem(Icons.calendar_today, widget.date),
                        _headerItem(Icons.people, '${widget.passengers} Pax'),
                        _headerItem(Icons.airline_seat_recline_normal, widget.classType),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sort chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sortChip('Cheapest First'),
                  _sortChip('Highest Rated'),
                  _sortChip('Departure Time'),
                  _sortChip('Duration'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sortedFlights.length,
                itemBuilder: (context, index) => _buildFlightCard(_sortedFlights[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  Widget _sortChip(String label) {
    final selected = _sortBy == label;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFlightCard(Map<String, dynamic> flight) {
    final isPremium = flight['premium'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF152A20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPremium
                      ? const Color(0xFFC49B63).withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flight,
                  color: isPremium ? const Color(0xFFC49B63) : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['airline'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? const Color(0xFFC49B63) : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${flight['code']} • ${flight['aircraft']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isPremium ? Colors.white70 : AppColors.textGrey,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12,
                            color: isPremium ? const Color(0xFFC49B63) : Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${flight['rating']} (${flight['reviews']})',
                          style: TextStyle(
                            fontSize: 10,
                            color: isPremium ? Colors.white70 : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC49B63),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PREMIUM',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight['departure'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.fromAirport['code']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white70 : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      flight['duration'],
                      style: TextStyle(fontSize: 11,
                          color: isPremium ? Colors.white70 : AppColors.textGrey),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isPremium ? Colors.white24 : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.flight, size: 14,
                              color: isPremium ? const Color(0xFFC49B63) : AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: isPremium ? Colors.white24 : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      flight['stops'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? const Color(0xFFC49B63) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    flight['arrival'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.toAirport['code']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white70 : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Terminal & Baggage
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _chip('Terminal ${flight['terminal']}', isPremium),
              _chip('Baggage ${flight['baggage']}', isPremium),
              _chip(widget.classType, isPremium),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PKR ${(flight['price'] as double).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? const Color(0xFFC49B63) : AppColors.primary,
                      ),
                    ),
                    Text(
                      'per passenger',
                      style: TextStyle(
                        fontSize: 10,
                        color: isPremium ? Colors.white70 : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _selectFlight(flight),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? const Color(0xFFC49B63) : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Select',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, bool isPremium) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPremium ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPremium ? Colors.white70 : AppColors.textDark,
        ),
      ),
    );
  }
}