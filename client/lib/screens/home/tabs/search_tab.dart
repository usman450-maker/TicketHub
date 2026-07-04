import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

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
                  const Icon(Icons.menu,
                      color: AppColors.primary, size: 26),
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
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/100?img=45',
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
            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 54,
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
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: AppColors.textGrey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Events, venues, cities...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.mic,
                        color: Color(0xFF6B8E7B), size: 22),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.borderGrey,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.tune, color: AppColors.textDark),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All Results', selected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Price', icon: Icons.attach_money),
                  const SizedBox(width: 8),
                  _buildFilterChip('Date', icon: Icons.calendar_today),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rating', icon: Icons.star_border),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Searches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildRecentSearch('Broadway Nights'),
                  const SizedBox(height: 10),
                  _buildRecentSearch('Tomorrowland'),
                  const SizedBox(height: 10),
                  _buildRecentSearch('London Concerts'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trending Now
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Big Trending Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBigTrendingCard(),
            ),
            const SizedBox(height: 12),

            // Two small cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSmallTrendingCard(
                      image:
                          'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
                      title: 'Neon Nights',
                      subtitle: 'Electric Park',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallTrendingCard(
                      image:
                          'https://images.unsplash.com/photo-1510076857177-7470076d4098?w=400',
                      title: 'Vineyard Gala',
                      subtitle: 'Napa Valley',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Popular Searches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department,
                            color: Color(0xFFC49B63), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Popular Searches',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPopularItem('Weekend Gateways'),
                    _buildPopularItem('Art Basel 2024'),
                    _buildPopularItem('VIP Sporting Events'),
                    _buildPopularItem('Broadway Premiers'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TicketHub Pass Card
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
                      'TicketHub Pass',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unlock early access to premium events and exclusive lounge entries.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          'Explore Benefits',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {bool selected = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1F3A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textDark),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearch(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.close, size: 18, color: AppColors.textGrey),
        ],
      ),
    );
  }

  Widget _buildBigTrendingCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1507924538820-ede94a04019d?w=800',
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC49B63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "EDITOR'S CHOICE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 100,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'London\nSymphony\nOrchestra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Royal Albert Hall • Oct 12',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: const [
                    Text(
                      'From',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      '\$89',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTrendingCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
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
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
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
    );
  }

  Widget _buildPopularItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right,
              color: AppColors.textGrey, size: 20),
        ],
      ),
    );
  }
}