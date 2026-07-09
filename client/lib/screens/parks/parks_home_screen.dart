import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/park_service.dart';
import 'park_detail_screen.dart';

class ParksHomeScreen extends StatefulWidget {
  const ParksHomeScreen({super.key});

  @override
  State<ParksHomeScreen> createState() => _ParksHomeScreenState();
}

class _ParksHomeScreenState extends State<ParksHomeScreen> {
  List<Map<String, dynamic>> _parks = [];
  bool _isLoading = true;
  String _selectedCity = 'All';
  final _searchController = TextEditingController();

  final List<String> _cities = [
  'All',
  'Lahore',
  'Karachi',
  'Islamabad',
  'Rawalpindi',
  'Multan',
  'Peshawar',
  'Faisalabad',
];
  @override
  void initState() {
    super.initState();
    _loadParks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParks() async {
    setState(() => _isLoading = true);

    final parks = await ParkService.getParks(
      city: _selectedCity == 'All' ? null : _selectedCity,
    );

    if (mounted) {
      setState(() {
        _parks = parks;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredParks {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _parks;

    return _parks.where((p) {
      return (p['name']?.toString() ?? '').toLowerCase().contains(query) ||
          (p['city']?.toString() ?? '').toLowerCase().contains(query) ||
          (p['category']?.toString() ?? '').toLowerCase().contains(query);
    }).toList();
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

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Theme Parks & Fun',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Unforgettable days at the best parks.',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textGrey)),
              ),
            ),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    hintText: 'Search parks...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textGrey, size: 20),
                    hintStyle:
                        TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // City filter
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final selected = _selectedCity == city;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCity = city);
                      _loadParks();
                    },
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
                                : AppColors.borderGrey),
                      ),
                      child: Text(city,
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
            const SizedBox(height: 16),

            // Parks list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : _filteredParks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.park,
                                  size: 80,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              const Text('No parks found',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textGrey)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadParks,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: _filteredParks.length,
                            itemBuilder: (context, index) {
                              return _buildParkCard(
                                  _filteredParks[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkCard(Map<String, dynamic> park) {
    final facilities = park['facilities'] as List? ?? [];
    final rating = double.tryParse(park['rating']?.toString() ?? '0') ?? 0;
    final adultPrice =
        double.tryParse(park['adult_price']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
      ),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: Image.network(
                park['poster']?.toString() ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                    height: 180, color: AppColors.primaryLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (park['category']?.toString() ?? '').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(park['name']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(park['city']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGrey)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(
                          '${park['opening_time'] ?? ''} - ${park['closing_time'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Facilities chips
                  if (facilities.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: facilities.take(4).map<Widget>((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(f.toString(),
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Color(0xFFC49B63)),
                          const SizedBox(width: 4),
                          Text('$rating (${park['reviews'] ?? '0'})',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Starting from',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textGrey)),
                          Text('PKR ${adultPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ],
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
}