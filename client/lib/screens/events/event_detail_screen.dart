import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/events_data.dart';
import '../../models/transport_booking.dart';
import '../transport/passenger_details_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _selectedTier = -1;
  int _ticketCount = 1;

  double get _selectedPrice {
    if (_selectedTier == -1) return 0;
    final tier = EventsData.ticketTiers[_selectedTier];
    return (widget.event['basePrice'] as double) * (tier['multiplier'] as double);
  }

  double get _totalPrice => _selectedPrice * _ticketCount;

  void _proceedToNext() {
    if (_selectedTier == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ticket tier')),
      );
      return;
    }

    final tier = EventsData.ticketTiers[_selectedTier];
    final e = widget.event;

    final passengers = List.generate(
      _ticketCount,
      (i) => Passenger(
        fullName: '', idNumber: '', gender: 'Male',
        age: 0, nationality: '', email: '', phone: '',
      ),
    );

    final booking = TransportBooking(
      transportType: 'event',
      operatorName: e['title'],
      operatorNumber: 'EVENT-${e['id']}',
      fromLocation: e['venue'],
      toLocation: e['city'],
      departureDate: e['date'],
      departureTime: e['time'],
      arrivalTime: e['endTime'],
      classType: tier['name'],
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
    final e = widget.event;
    final artists = (e['artists'] as List?) ?? [];

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
                    // Hero Image
                    Stack(
                      children: [
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(e['image']),
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
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _circleButton(Icons.arrow_back, () => Navigator.pop(context)),
                                Row(
                                  children: [
                                    _circleButton(Icons.notifications_outlined, () {}),
                                    const SizedBox(width: 8),
                                    _circleButton(Icons.share, () {}),
                                  ],
                                ),
                              ],
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('VERIFIED EXPERIENCE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                              ),
                              const SizedBox(height: 10),
                              Text(e['title'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.white70, size: 12),
                                  const SizedBox(width: 4),
                                  Text(e['date'],
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                  const SizedBox(width: 4),
                                  Text('${e['venue']}, ${e['city']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.white70, size: 12),
                                  const SizedBox(width: 4),
                                  Text('${e['time']} - ${e['endTime']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          const Text('The Experience',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(e['description'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.textGrey, height: 1.6)),
                          const SizedBox(height: 20),

                          // Artists
                     // Artists
if (artists.isNotEmpty) ...[
  const Text('Artist Lineup',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  const SizedBox(height: 12),
  SizedBox(
    height: 140,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final roles = ['HEADLINER', 'SUPPORT', 'OPENING ACT', 'PERFORMER', 'GUEST'];
        
        // Real artist images from Unsplash
        final artistImages = [
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400',
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400',
          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
        ];

        final imageUrl = index < artistImages.length
            ? artistImages[index]
            : artistImages[index % artistImages.length];

        return Container(
          width: 130,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      child: const Center(
                        child: Icon(Icons.music_note,
                            color: AppColors.primary, size: 30),
                      ),
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
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artists[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        index < roles.length ? roles[index] : 'PERFORMER',
                        style: const TextStyle(
                          color: Color(0xFFC49B63),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
  const SizedBox(height: 20),
],

                          // Venue Info
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Venue Information',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text('${e['venue']}\n${e['city']}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                _venueDetail(Icons.directions_bus, 'Public transport available'),
                                _venueDetail(Icons.local_parking, 'Parking included'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Ticket Tiers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Ticket',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('From PKR ${(e['basePrice'] as double).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ...EventsData.ticketTiers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tier = entry.value;
                            final price = (e['basePrice'] as double) * (tier['multiplier'] as double);
                            final selected = _selectedTier == index;
                            final color = Color(int.parse('0xFF${tier['color']}'));

                            return GestureDetector(
                              onTap: () => setState(() => _selectedTier = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: selected ? color.withValues(alpha: 0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? color : AppColors.borderGrey,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(tier['code'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tier['name'],
                                              style: const TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.bold)),
                                          Text(tier['description'],
                                              style: const TextStyle(
                                                  fontSize: 11, color: AppColors.textGrey)),
                                        ],
                                      ),
                                    ),
                                    Text('PKR ${price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: color)),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Ticket count
                          if (_selectedTier != -1)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Number of Tickets',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (_ticketCount > 1) setState(() => _ticketCount--);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: AppColors.primary),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('$_ticketCount',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary)),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (_ticketCount < 10) setState(() => _ticketCount++);
                                        },
                                        icon: const Icon(Icons.add_circle,
                                            color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Rating
                          if (e['rating'] != null)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFC49B63), size: 16),
                                const SizedBox(width: 4),
                                Text('${e['rating']} / 5 Rating',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text('Based on ${e['reviews']}+ reviews',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                              ],
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom
            if (_selectedTier != -1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderGrey)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _proceedToNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Book Tickets from PKR ${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _venueDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}