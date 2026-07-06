import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../transport/passenger_details_screen.dart';

class TrainListScreen extends StatefulWidget {
  final Map<String, String> fromStation;
  final Map<String, String> toStation;
  final String date;
  final int passengers;
  final String classType;

  const TrainListScreen({
    super.key,
    required this.fromStation,
    required this.toStation,
    required this.date,
    required this.passengers,
    required this.classType,
  });

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
  String _sortBy = 'Cheapest First';

  double get _priceMultiplier {
    if (widget.classType.contains('AC Sleeper')) return 3.0;
    if (widget.classType.contains('AC Business')) return 2.5;
    if (widget.classType.contains('AC Standard')) return 2.0;
    if (widget.classType.contains('Parlor')) return 3.5;
    return 1.0;
  }

  List<Map<String, dynamic>> get _trains {
    final base = [
      {
        'name': 'Green Line Express',
        'number': '5DN',
        'bogies': 18,
        'rating': 4.8,
        'reviews': '5.2k',
        'departure': '05:00',
        'arrival': '22:00',
        'duration': '17h 00m',
        'stops': '12 Stops',
        'basePrice': 2500.00,
        'amenities': ['AC', 'Meals', 'WiFi', 'Sleeper'],
      },
      {
        'name': 'Pakistan Express',
        'number': '35DN',
        'bogies': 15,
        'rating': 4.5,
        'reviews': '3.8k',
        'departure': '07:30',
        'arrival': '02:45',
        'duration': '19h 15m',
        'stops': '18 Stops',
        'basePrice': 1800.00,
        'amenities': ['AC', 'Meals'],
      },
      {
        'name': 'Karakoram Express',
        'number': '13UP',
        'bogies': 13,
        'rating': 4.7,
        'reviews': '4.5k',
        'departure': '13:00',
        'arrival': '05:30',
        'duration': '16h 30m',
        'stops': '10 Stops',
        'basePrice': 2200.00,
        'amenities': ['AC', 'Meals', 'Sleeper', 'Wifi'],
        'premium': true,
      },
      {
        'name': 'Business Express',
        'number': '25UP',
        'bogies': 10,
        'rating': 4.9,
        'reviews': '2.5k',
        'departure': '16:00',
        'arrival': '07:15',
        'duration': '15h 15m',
        'stops': '6 Stops',
        'basePrice': 3200.00,
        'amenities': ['AC', 'Meals', 'WiFi', 'Business'],
        'premium': true,
      },
      {
        'name': 'Awam Express',
        'number': '11UP',
        'bogies': 20,
        'rating': 4.2,
        'reviews': '2.1k',
        'departure': '19:30',
        'arrival': '15:00',
        'duration': '19h 30m',
        'stops': '22 Stops',
        'basePrice': 1500.00,
        'amenities': ['AC', 'Standard'],
      },
      {
        'name': 'Shalimar Express',
        'number': '27DN',
        'bogies': 14,
        'rating': 4.4,
        'reviews': '1.8k',
        'departure': '21:00',
        'arrival': '16:30',
        'duration': '19h 30m',
        'stops': '15 Stops',
        'basePrice': 1700.00,
        'amenities': ['AC', 'Meals'],
      },
    ];

    return base.map((t) => {
      ...t,
      'price': (t['basePrice'] as double) * _priceMultiplier,
    }).toList();
  }

  List<Map<String, dynamic>> get _sortedTrains {
    final list = List<Map<String, dynamic>>.from(_trains);
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
    }
    return list;
  }

  void _selectTrain(Map<String, dynamic> train) {
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
      transportType: 'train',
      operatorName: train['name'],
      operatorNumber: train['number'],
      fromLocation: '${widget.fromStation['city']} (${widget.fromStation['code']})',
      toLocation: '${widget.toStation['city']} (${widget.toStation['code']})',
      departureDate: widget.date,
      departureTime: train['departure'],
      arrivalTime: train['arrival'],
      duration: train['duration'],
      classType: widget.classType,
      pricePerPassenger: train['price'],
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
                                widget.fromStation['code']!,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.fromStation['city']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.train, color: Colors.white),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.toStation['code']!,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.toStation['city']!,
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

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sortChip('Cheapest First'),
                  _sortChip('Highest Rated'),
                  _sortChip('Departure Time'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sortedTrains.length,
                itemBuilder: (context, index) => _buildTrainCard(_sortedTrains[index]),
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
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderGrey),
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

  Widget _buildTrainCard(Map<String, dynamic> train) {
    final isPremium = train['premium'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF152A20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                      ? const Color(0xFFC49B63).withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.train,
                  color: isPremium ? const Color(0xFFC49B63) : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      train['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? const Color(0xFFC49B63) : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Train #${train['number']} • ${train['bogies']} Bogies',
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
                          '${train['rating']} (${train['reviews']})',
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
                    train['departure'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.fromStation['code']!,
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
                      train['duration'],
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
                          Icon(Icons.train, size: 14,
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
                      train['stops'],
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
                    train['arrival'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.toStation['code']!,
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

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (train['amenities'] as List<String>).map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isPremium ? Colors.white.withOpacity(0.1) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                a,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isPremium ? Colors.white70 : AppColors.textDark,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PKR ${(train['price'] as double).toStringAsFixed(0)}',
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
                onPressed: () => _selectTrain(train),
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
}