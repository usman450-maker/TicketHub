import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/events_data.dart';
import 'event_detail_screen.dart';

class EventsHomeScreen extends StatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  State<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends State<EventsHomeScreen> {
  String _selectedCategory = 'For You';
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  List<Map<String, dynamic>> get _featuredEvents =>
      EventsData.events.where((e) => e['featured'] == true).toList();

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedCategory == 'For You') return EventsData.events;
    return EventsData.events
        .where((e) => e['category'] == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients && _featuredEvents.isNotEmpty) {
        _currentBanner = (_currentBanner + 1) % _featuredEvents.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    ),
                    const Text('TicketHub',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: AppColors.textGrey, size: 20),
                            SizedBox(width: 8),
                            Text('Search concerts, shows...',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categories
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: EventsData.categories.length,
                  itemBuilder: (context, index) {
                    final cat = EventsData.categories[index];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.borderGrey,
                          ),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                                color: selected ? Colors.white : AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Trending Now
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Trending Now',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('View All',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Featured Banner
              if (_featuredEvents.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _featuredEvents.length,
                    onPageChanged: (i) => setState(() => _currentBanner = i),
                    itemBuilder: (context, index) {
                      return _buildFeaturedCard(_featuredEvents[index]);
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _featuredEvents.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: _currentBanner == i ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentBanner == i
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Discover More
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Discover More',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              // Events List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _filteredEvents.map((e) => _buildEventCard(e)).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(event['image'], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight)),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),
              // Tags
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: (event['tags'] as List).map<Widget>((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['title'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.1)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('${event['date']}',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, color: Colors.white70, size: 12),
                        Text(' ${event['venue']}, ${event['city']}',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('From PKR ${(event['basePrice'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Color(0xFFC49B63),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Book Tickets',
                              style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Image.network(event['image'],
                      height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(height: 180, color: AppColors.primaryLight)),
                ),
                // Date badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        Text(
                          event['date'].toString().split(' ')[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        Text(
                          event['date'].toString().split(' ')[1].replaceAll(',', ''),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['category'].toString().toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(event['title'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text('${event['venue']}, ${event['city']}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if ((event['seatsLeft'] as int) < 200)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text('SELLING FAST',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB91C1C))),
                            ),
                          if (event['rating'] != null)
                            Row(
                              children: [
                                const Icon(Icons.star, size: 12, color: Color(0xFFC49B63)),
                                const SizedBox(width: 2),
                                Text('${event['rating']} (${event['reviews']})',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                              ],
                            ),
                        ],
                      ),
                      Text('PKR ${(event['basePrice'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
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
}