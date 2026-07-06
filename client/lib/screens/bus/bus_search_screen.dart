import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/cities_data.dart';
import 'bus_list_screen.dart';

class BusSearchScreen extends StatefulWidget {
  const BusSearchScreen({super.key});

  @override
  State<BusSearchScreen> createState() => _BusSearchScreenState();
}

class _BusSearchScreenState extends State<BusSearchScreen> {
  String _fromCity = 'Lahore';
  String _toCity = 'Islamabad';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

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
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients) {
        _currentBanner = (_currentBanner + 1) % CitiesData.busBanners.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromCity;
      _fromCity = _toCity;
      _toCity = temp;
    });
  }

  Future<void> _pickCity(bool isFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerBottomSheet(
        title: isFrom ? 'Select Departure City' : 'Select Destination City',
        excludeCity: isFrom ? _toCity : _fromCity,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromCity = selected;
        } else {
          _toCity = selected;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _searchBuses() {
    if (_fromCity == _toCity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To cities cannot be same')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusListScreen(
          from: _fromCity,
          to: _toCity,
          date: '${_selectedDate.day} ${_getMonth(_selectedDate.month)}, ${_selectedDate.year}',
        ),
      ),
    );
  }

  void _selectPopularRoute(Map<String, dynamic> route) {
    setState(() {
      _fromCity = route['from'];
      _toCity = route['to'];
    });
  }

  String _getMonth(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
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
                    const Text(
                      'TicketHub',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.textDark),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  'Where to next?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Secure your luxury transit with ease.',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================
              // AUTO-SCROLLING BANNER
              // ==========================
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: CitiesData.busBanners.length,
                  onPageChanged: (i) => setState(() => _currentBanner = i),
                  itemBuilder: (context, index) {
                    final banner = CitiesData.busBanners[index];
                    return _buildBanner(banner);
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Banner indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  CitiesData.busBanners.length,
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

              // ==========================
              // SEARCH BOX
              // ==========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildLocationField(
                        'From', _fromCity, Icons.location_on_outlined,
                        () => _pickCity(true)),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          GestureDetector(
                            onTap: _swapLocations,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.swap_vert,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildLocationField(
                        'To', _toCity, Icons.location_pin,
                        () => _pickCity(false)),
                      const SizedBox(height: 12),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _searchBuses,
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text(
                            'SEARCH BUSES',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================
              // POPULAR ROUTES
              // ==========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popular Routes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap to auto-fill route',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: CitiesData.popularRoutes.length,
                  itemBuilder: (context, index) {
                    return _buildRouteCard(CitiesData.popularRoutes[index]);
                  },
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                banner['image']!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Color(int.parse('0xFF${banner['color']}')),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        banner['tagline']!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
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

  Widget _buildLocationField(
      String label, String city, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departure',
            style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_getMonth(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return GestureDetector(
      onTap: () => _selectPopularRoute(route),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  route['image'],
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
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          route['from'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            route['to'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        route['price'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

// ==========================
// CITY PICKER BOTTOM SHEET
// ==========================
class _CityPickerBottomSheet extends StatefulWidget {
  final String title;
  final String excludeCity;

  const _CityPickerBottomSheet({
    required this.title,
    required this.excludeCity,
  });

  @override
  State<_CityPickerBottomSheet> createState() => _CityPickerBottomSheetState();
}

class _CityPickerBottomSheetState extends State<_CityPickerBottomSheet> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = CitiesData.pakistanCities
        .where((c) => c['name'] != widget.excludeCity)
        .toList();
  }

  void _filter(String query) {
    setState(() {
      _filteredCities = CitiesData.pakistanCities
          .where((c) =>
              c['name'] != widget.excludeCity &&
              c['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _filter,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textGrey),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_city,
                        color: AppColors.primary, size: 22),
                  ),
                  title: Text(
                    city['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    city['province']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      city['code']!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, city['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}