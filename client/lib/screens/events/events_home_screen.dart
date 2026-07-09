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
  final _searchController = TextEditingController();
  String _sortBy = 'Default';
  String _priceRange = 'All';

  List<Map<String, dynamic>> get _featuredEvents =>
      EventsData.events.where((e) => e['featured'] == true).toList();

  List<Map<String, dynamic>> get _filteredEvents {
    List<Map<String, dynamic>> result;

    if (_selectedCategory == 'For You') {
      result = List.from(EventsData.events);
    } else {
      result = EventsData.events
          .where((e) => e['category'] == _selectedCategory)
          .toList();
    }

    // Search
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      result = result.where((e) {
        final title = (e['title'] as String).toLowerCase();
        final venue = (e['venue'] as String).toLowerCase();
        final city = (e['city'] as String).toLowerCase();
        final category = (e['category'] as String).toLowerCase();
        return title.contains(query) ||
            venue.contains(query) ||
            city.contains(query) ||
            category.contains(query);
      }).toList();
    }

    // Price filter
    if (_priceRange == 'Under PKR 5,000') {
      result = result.where((e) => (e['basePrice'] as double) < 5000).toList();
    } else if (_priceRange == 'PKR 5,000 - 10,000') {
      result = result.where((e) {
        final p = e['basePrice'] as double;
        return p >= 5000 && p <= 10000;
      }).toList();
    } else if (_priceRange == 'Above PKR 10,000') {
      result =
          result.where((e) => (e['basePrice'] as double) > 10000).toList();
    }

    // Sort
    if (_sortBy == 'Price: Low to High') {
      result.sort((a, b) =>
          (a['basePrice'] as double).compareTo(b['basePrice'] as double));
    } else if (_sortBy == 'Price: High to Low') {
      result.sort((a, b) =>
          (b['basePrice'] as double).compareTo(a['basePrice'] as double));
    } else if (_sortBy == 'Rating') {
      result.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }

    return result;
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
    _searchController.dispose();
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.tune, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text('Filter & Sort',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sort By',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Default',
                            'Price: Low to High',
                            'Price: High to Low',
                            'Rating'
                          ].map((s) {
                            final selected = _sortBy == s;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {});
                                setState(() => _sortBy = s);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(s,
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Text('Price Range',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'All',
                            'Under PKR 5,000',
                            'PKR 5,000 - 10,000',
                            'Above PKR 10,000'
                          ].map((p) {
                            final selected = _priceRange == p;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {});
                                setState(() => _priceRange = p);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(p,
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _sortBy = 'Default';
                                    _priceRange = 'All';
                                  });
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: const Text('Reset',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: const Text('Apply',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.primary),
                    ),
                    const Text('TicketHub',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.textDark),
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
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Search concerts, shows...',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.textGrey, size: 20),
                            hintStyle: TextStyle(
                                color: AppColors.textGrey, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune,
                            color: Colors.white, size: 20),
                      ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.borderGrey,
                          ),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark,
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
                  children: [
                    const Text('Trending Now',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = 'For You'),
                      child: const Text('View All',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ),
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
                    onPageChanged: (i) =>
                        setState(() => _currentBanner = i),
                    itemBuilder: (context, index) {
                      return _buildFeaturedCard(
                          _featuredEvents[index]);
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
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Discover More
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discover More',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${_filteredEvents.length} events',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Events List
              if (_filteredEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 60,
                            color: AppColors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No events found',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textGrey)),
                        const SizedBox(height: 4),
                        const Text('Try different search or filter',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _filteredEvents
                        .map((e) => _buildEventCard(e))
                        .toList(),
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
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(event['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: AppColors.primaryLight)),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8)
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: (event['tags'] as List).map<Widget>((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 12),
                        Text(
                            ' ${event['venue']}, ${event['city']}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                            'From PKR ${(event['basePrice'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Color(0xFFC49B63),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
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
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Image.network(event['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                          height: 180,
                          color: AppColors.primaryLight)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4)
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          event['date']
                              .toString()
                              .split(' ')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        Text(
                          event['date']
                              .toString()
                              .split(' ')[1]
                              .replaceAll(',', ''),
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(
                          '${event['venue']}, ${event['city']}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if ((event['seatsLeft'] as int) < 500)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(
                                  right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius:
                                    BorderRadius.circular(3),
                              ),
                              child: const Text('SELLING FAST',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Color(
                                          0xFFB91C1C))),
                            ),
                          if (event['rating'] != null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 12,
                                    color: Color(0xFFC49B63)),
                                const SizedBox(width: 2),
                                Text(
                                    '${event['rating']} (${event['reviews']})',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.textGrey)),
                              ],
                            ),
                        ],
                      ),
                      Text(
                          'PKR ${(event['basePrice'] as double).toStringAsFixed(0)}',
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