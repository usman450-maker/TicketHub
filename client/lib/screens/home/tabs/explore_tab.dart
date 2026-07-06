import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/storage_service.dart';
import '../widgets/category_item.dart';
import '../widgets/trending_card.dart';
import '../../../core/routes/route_names.dart';
import '../../bus/bus_search_screen.dart';
import '../../flight/flight_search_screen.dart';
import '../../train/train_search_screen.dart';
import '../../sports/sports_home_screen.dart';
import '../../events/events_home_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (mounted && user != null) {
      setState(() {
        _userName = user['name']?.toString().split(' ').first ?? 'Guest';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: AppColors.textDark, size: 26),
                  const SizedBox(width: 14),
                  const Text(
                    'TicketHub',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.borderGrey, width: 1),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/100?img=13',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_userName',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Where would you like to go today?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search movies, flights, or events...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.textGrey),
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Categories Grid
            // Categories Grid
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CategoryItem(
            icon: Icons.movie_outlined,
            label: 'Movies',
            onTap: () => Navigator.pushNamed(context, RouteNames.movies),
          ),
          CategoryItem(
  icon: Icons.directions_bus_outlined,
  label: 'Bus',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const BusSearchScreen()),
  ),
),
          CategoryItem(
  icon: Icons.train,
  label: 'Train',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TrainSearchScreen()),
  ),
),
          CategoryItem(
  icon: Icons.flight,
  label: 'Flights',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const FlightSearchScreen()),
  ),
),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:  [
          CategoryItem(
  icon: Icons.event_seat,
  label: 'Events',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EventsHomeScreen()),
  ),
),
          CategoryItem(
  icon: Icons.sports_soccer,
  label: 'Sports',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SportsHomeScreen()),
  ),
),
          CategoryItem(icon: Icons.park_outlined, label: 'Parks'),
          CategoryItem(icon: Icons.apps, label: 'More'),
        ],
      ),
    ],
  ),
),
            const SizedBox(height: 32),

            // Exclusive Travel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Exclusive Travel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildExclusiveCard(
                    image:
                        'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
                    tag: 'CURATED',
                    title: 'Private Jet Escape',
                    subtitle: 'Paris to Maldives, Non-stop Luxury',
                  ),
                  const SizedBox(width: 12),
                  _buildExclusiveCard(
                    image:
                        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
                    tag: 'CURATED',
                    title: 'Beach Resort',
                    subtitle: 'Bali Paradise Getaway',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Trending Now
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Trending Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  TrendingCard(
                    image:
                        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=600',
                    title: 'Eras Tour: Special Edition',
                    location: 'Los Angeles, CA',
                    price: '\$199.00',
                    tag: 'Selling Fast',
                  ),
                  TrendingCard(
                    image:
                        'https://images.unsplash.com/photo-1503095396549-807759245b35?w=600',
                    title: 'The Phantom',
                    location: 'New York, NY',
                    price: '\$120.00',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Exclusive Offers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Exclusive Offers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Offer Card 1 (Dark Green)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEMBER SPECIAL',
                      style: TextStyle(
                        color: Color(0xFFC49B63),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get 20% Off',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'On your first flight booking this month.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Claim Offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Offer Card 2 (Light Green)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFDCC9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REFER A FRIEND',
                      style: TextStyle(
                        color: Color(0xFF1F3A2E),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$50 Reward',
                      style: TextStyle(
                        color: Color(0xFF1F3A2E),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Earn credit for every successful referral.',
                      style: TextStyle(
                        color: Color(0xFF1F3A2E),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F3A2E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Invite Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Recommended
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildRecommendCard(
                      image:
                          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
                      title: 'Culinary Art Night',
                      subtitle: 'May 12 • Modern Gallery',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRecommendCard(
                      image:
                          'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=400',
                      title: 'Midnight Jazz Session',
                      subtitle: 'May 15 • Blue Note',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildExclusiveCard({
    required String image,
    required String tag,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryLight,
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
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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

  Widget _buildRecommendCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 130,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}