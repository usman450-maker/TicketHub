import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/sports_data.dart';
import 'match_detail_screen.dart';

class SportsHomeScreen extends StatefulWidget {
  const SportsHomeScreen({super.key});

  @override
  State<SportsHomeScreen> createState() => _SportsHomeScreenState();
}

class _SportsHomeScreenState extends State<SportsHomeScreen> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;
  String _selectedCategory = 'All Sports';
  final _searchController = TextEditingController();

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
      if (_bannerController.hasClients) {
        _currentBanner = (_currentBanner + 1) % SportsData.matchBanners.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_hockey':
        return Icons.sports_hockey;
      case 'sports_tennis':
        return Icons.sports_tennis;
      case 'sports_basketball':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }

  List<Map<String, dynamic>> get _filteredMatches {
    if (_selectedCategory == 'All Sports') return SportsData.matches;
    return SportsData.matches
        .where((m) => m['sport'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _liveMatches =>
      _filteredMatches.where((m) => m['featured'] == true).toList();

  List<Map<String, dynamic>> get _upcomingMatches =>
      _filteredMatches.where((m) => m['featured'] != true).toList();

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
                    const Text(
                      'TicketHub',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(Icons.person, color: AppColors.textGrey, size: 20),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================
              // FEATURED BANNER
              // ==========================
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: SportsData.matchBanners.length,
                  onPageChanged: (i) => setState(() => _currentBanner = i),
                  itemBuilder: (context, index) {
                    return _buildBanner(SportsData.matchBanners[index]);
                  },
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  SportsData.matchBanners.length,
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
              const SizedBox(height: 20),

              // ==========================
              // CATEGORIES
              // ==========================
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: SportsData.categories.length,
                  itemBuilder: (context, index) {
                    final cat = SportsData.categories[index];
                    final selected = _selectedCategory == cat['name'];

                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat['name']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.borderGrey,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForCategory(cat['icon']),
                              size: 16,
                              color: selected ? Colors.white : AppColors.textDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ==========================
              // LIVE & FEATURED MATCHES
              // ==========================
              if (_liveMatches.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Live & Upcoming Matches',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Catch the intensity of world-class athletics.',
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _liveMatches.length,
                    itemBuilder: (context, index) {
                      return _buildFeaturedMatchCard(_liveMatches[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ==========================
              // ALL MATCHES
              // ==========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'All Matches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _upcomingMatches
                      .map((m) => _buildMatchCard(m))
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

  Widget _buildBanner(Map<String, String> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                banner['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC49B63),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      banner['subtitle']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Text(
                    banner['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textGrey, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Search sports, matches...',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 13),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.tune,
                              color: Colors.white, size: 16),
                        ),
                      ],
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

  Widget _buildFeaturedMatchCard(Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
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
                  child: Image.network(
                    match['image'],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                if (match['status'] == 'LIVE')
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.white, size: 6),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match['league'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match['team1']} vs ${match['team2']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: AppColors.textGrey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${match['venue']}, ${match['city']}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FROM',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PKR ${(match['basePrice'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (match['seatsLeft'] as int) < 100
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (match['seatsLeft'] as int) < 100
                              ? 'Limited Seats'
                              : '${match['seatsLeft']}+ Seats',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: (match['seatsLeft'] as int) < 100
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFF065F46),
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

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailScreen(match: match),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match['league'],
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match['sport'],
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  match['date'],
                  style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Teams
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            match['team1Short'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['team1'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      match['time'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC49B63).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            match['team2Short'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC49B63),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['team2'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Venue
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${match['venue']}, ${match['city']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STARTING FROM',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'PKR ${(match['basePrice'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchDetailScreen(match: match),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}