import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transport_booking.dart';
import '../transport/passenger_details_screen.dart';

class BusListScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;

  const BusListScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  String _sortBy = 'Cheapest First';

List<Map<String, dynamic>> get _buses => [
    {
      'name': 'Faisal Movers',
      'number': 'FM-101',
      'rating': 4.8,
      'reviews': '2.1k',
      'departure': '06:00',
      'departure_location': 'THOKAR',
      'arrival': '10:15',
      'arrival_location': 'G-11',
      'duration': '4h 15m',
      'stops': 'DIRECT JOURNEY',
      'price': 4500.00,  // PKR
      'class': 'EXECUTIVE',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Snacks'],
    },
    {
      'name': 'Daewoo Express',
      'number': 'DE-202',
      'rating': 4.6,
      'reviews': '1.8k',
      'departure': '07:30',
      'departure_location': 'KALMA',
      'arrival': '12:00',
      'arrival_location': 'TERMINAL',
      'duration': '4h 30m',
      'stops': '1 STOP',
      'price': 3800.00,  // PKR
      'class': 'BUSINESS',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'USB'],
    },
    {
      'name': 'Sania Express',
      'number': 'SE-303',
      'rating': 4.9,
      'reviews': '3k',
      'departure': '08:45',
      'departure_location': 'THOKAR',
      'arrival': '12:45',
      'arrival_location': 'G-11',
      'duration': '4h 00m',
      'stops': 'VIP NON-STOP',
      'price': 6500.00,  // PKR
      'class': 'ULTRA LUXURY',
      'premium': true,
      'amenities': ['WiFi', 'AC', 'Meals', 'TV', 'Recliner'],
    },
    {
      'name': 'Q-Connect',
      'number': 'QC-404',
      'rating': 4.5,
      'reviews': '1.2k',
      'departure': '09:15',
      'departure_location': 'STATION',
      'arrival': '13:30',
      'arrival_location': 'CENTRAL',
      'duration': '4h 15m',
      'stops': 'DIRECT',
      'price': 4200.00,
      'class': 'STANDARD',
      'premium': false,
      'amenities': ['AC', 'Water'],
    },
    {
      'name': 'Bilal Travels',
      'number': 'BT-505',
      'rating': 4.7,
      'reviews': '900',
      'departure': '10:00',
      'departure_location': 'THOKAR',
      'arrival': '14:30',
      'arrival_location': 'G-11',
      'duration': '4h 30m',
      'stops': '1 STOP',
      'price': 4800.00,
      'class': 'EXECUTIVE',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Snacks', 'USB'],
    },
    {
      'name': 'Skyways',
      'number': 'SW-606',
      'rating': 4.4,
      'reviews': '750',
      'departure': '11:30',
      'departure_location': 'KALMA',
      'arrival': '16:00',
      'arrival_location': 'TERMINAL',
      'duration': '4h 30m',
      'stops': '2 STOPS',
      'price': 3500.00,
      'class': 'STANDARD',
      'premium': false,
      'amenities': ['AC'],
    },
    {
      'name': 'Kohistan Express',
      'number': 'KE-707',
      'rating': 4.6,
      'reviews': '1.5k',
      'departure': '12:00',
      'departure_location': 'STATION',
      'arrival': '16:30',
      'arrival_location': 'CENTRAL',
      'duration': '4h 30m',
      'stops': 'DIRECT',
      'price': 5200.00,
      'class': 'BUSINESS',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Refreshments'],
    },
    {
      'name': 'Royal Ride',
      'number': 'RR-808',
      'rating': 4.9,
      'reviews': '2.5k',
      'departure': '14:00',
      'departure_location': 'THOKAR',
      'arrival': '18:00',
      'arrival_location': 'G-11',
      'duration': '4h 00m',
      'stops': 'VIP NON-STOP',
      'price': 7500.00,
      'class': 'ULTRA LUXURY',
      'premium': true,
      'amenities': ['WiFi', 'AC', 'Meals', 'TV', 'Recliner', 'Charging'],
    },
    {
      'name': 'Niazi Express',
      'number': 'NE-909',
      'rating': 4.3,
      'reviews': '600',
      'departure': '15:30',
      'departure_location': 'STATION',
      'arrival': '20:00',
      'arrival_location': 'CENTRAL',
      'duration': '4h 30m',
      'stops': '1 STOP',
      'price': 3000.00,
      'class': 'STANDARD',
      'premium': false,
      'amenities': ['AC', 'Water'],
    },
    {
      'name': 'Sammi Daewoo',
      'number': 'SD-010',
      'rating': 4.5,
      'reviews': '1.1k',
      'departure': '16:00',
      'departure_location': 'KALMA',
      'arrival': '20:30',
      'arrival_location': 'TERMINAL',
      'duration': '4h 30m',
      'stops': 'DIRECT',
      'price': 4600.00,
      'class': 'EXECUTIVE',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Snacks'],
    },
    {
      'name': 'Kainat Travels',
      'number': 'KT-111',
      'rating': 4.2,
      'reviews': '500',
      'departure': '18:00',
      'departure_location': 'STATION',
      'arrival': '22:30',
      'arrival_location': 'CENTRAL',
      'duration': '4h 30m',
      'stops': '2 STOPS',
      'price': 2800.00,
      'class': 'STANDARD',
      'premium': false,
      'amenities': ['AC'],
    },
    {
      'name': 'Al-Makkah Travels',
      'number': 'AM-212',
      'rating': 4.8,
      'reviews': '1.8k',
      'departure': '20:00',
      'departure_location': 'THOKAR',
      'arrival': '00:15',
      'arrival_location': 'G-11',
      'duration': '4h 15m',
      'stops': 'DIRECT',
      'price': 5500.00,
      'class': 'BUSINESS',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Meals', 'Blanket'],
    },
    {
      'name': 'Manthar Travels',
      'number': 'MT-313',
      'rating': 4.4,
      'reviews': '800',
      'departure': '22:00',
      'departure_location': 'KALMA',
      'arrival': '02:30',
      'arrival_location': 'TERMINAL',
      'duration': '4h 30m',
      'stops': 'NIGHT COACH',
      'price': 4400.00,
      'class': 'EXECUTIVE',
      'premium': false,
      'amenities': ['AC', 'Blanket', 'Water'],
    },
    {
      'name': 'Amanat Ali',
      'number': 'AA-414',
      'rating': 4.6,
      'reviews': '1.3k',
      'departure': '23:30',
      'departure_location': 'STATION',
      'arrival': '04:00',
      'arrival_location': 'CENTRAL',
      'duration': '4h 30m',
      'stops': 'NIGHT COACH',
      'price': 5000.00,
      'class': 'BUSINESS',
      'premium': false,
      'amenities': ['WiFi', 'AC', 'Blanket', 'Meals'],
    },
  ];

  List<Map<String, dynamic>> get _sortedBuses {
    final list = List<Map<String, dynamic>>.from(_buses);
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

  void _selectBus(Map<String, dynamic> bus) {
    final booking = TransportBooking(
      transportType: 'bus',
      operatorName: bus['name'],
      operatorNumber: bus['number'],
      fromLocation: widget.from,
      toLocation: widget.to,
      departureDate: widget.date,
      departureTime: bus['departure'],
      arrivalTime: bus['arrival'],
      duration: bus['duration'],
      classType: bus['class'],
      pricePerPassenger: bus['price'],
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.from,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.date,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.to,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_sortedBuses.length} buses',
                            style: const TextStyle(
                              color: Colors.white70,
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
            const SizedBox(height: 16),

            // Sort options
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
                itemCount: _sortedBuses.length,
                itemBuilder: (context, index) => _buildBusCard(_sortedBuses[index]),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildBusCard(Map<String, dynamic> bus) {
    final isPremium = bus['premium'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF152A20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
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
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: isPremium ? const Color(0xFFC49B63) : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPremium
                            ? const Color(0xFFC49B63)
                            : AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 12,
                            color: isPremium
                                ? const Color(0xFFC49B63)
                                : Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${bus['rating']} (${bus['reviews']})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isPremium
                                ? Colors.white70
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC49B63),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ULTRA LUXURY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
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
                    bus['departure'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.from,
                    style: TextStyle(
                        fontSize: 9,
                        color: isPremium ? Colors.white70 : AppColors.textGrey),
                  ),
                  Text(
                    bus['departure_location'],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPremium ? Colors.white70 : AppColors.textDark),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      bus['duration'],
                      style: TextStyle(
                          fontSize: 11,
                          color: isPremium ? Colors.white70 : AppColors.textGrey),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      color: isPremium ? Colors.white24 : Colors.grey.shade300,
                    ),
                    Text(
                      bus['stops'],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isPremium
                            ? const Color(0xFFC49B63)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bus['arrival'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    widget.to,
                    style: TextStyle(
                        fontSize: 9,
                        color: isPremium ? Colors.white70 : AppColors.textGrey),
                  ),
                  Text(
                    bus['arrival_location'],
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPremium ? Colors.white70 : AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amenities
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (bus['amenities'] as List<String>).map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  a,
                  style: TextStyle(
                    fontSize: 9,
                    color: isPremium ? Colors.white70 : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PKR ${bus['price'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isPremium
                            ? const Color(0xFFC49B63)
                            : AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? const Color(0xFFC49B63).withValues(alpha: 0.2)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bus['class'],
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isPremium
                              ? const Color(0xFFC49B63)
                              : const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _selectBus(bus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium
                      ? const Color(0xFFC49B63)
                      : AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}