import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/cities_data.dart';
import 'flight_list_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  Map<String, String> _fromAirport = CitiesData.airports[0];
  Map<String, String> _toAirport = CitiesData.airports[8]; // Dubai
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _returnDate;
  int _passengers = 1;
  String _classType = 'Economy';
  bool _isRoundTrip = false;

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  final List<String> _classes = ['Economy', 'Business', 'First Class'];

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
        _currentBanner =
            (_currentBanner + 1) % CitiesData.airlineBanners.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _swapAirports() {
    setState(() {
      final temp = _fromAirport;
      _fromAirport = _toAirport;
      _toAirport = temp;
    });
  }

  Future<void> _pickAirport(bool isFrom) async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AirportPickerBottomSheet(
        title: isFrom ? 'Departure Airport' : 'Arrival Airport',
        excludeCode: isFrom ? _toAirport['code']! : _fromAirport['code']!,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromAirport = selected;
        } else {
          _toAirport = selected;
        }
      });
    }
  }

  Future<void> _pickDate(bool isDeparture) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? _departureDate
          : (_returnDate ?? _departureDate.add(const Duration(days: 1))),
      firstDate: isDeparture ? DateTime.now() : _departureDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  void _searchFlights() {
    if (_fromAirport['code'] == _toAirport['code']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To airports cannot be same')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightListScreen(
          fromAirport: _fromAirport,
          toAirport: _toAirport,
          date: _formatDate(_departureDate),
          passengers: _passengers,
          classType: _classType,
        ),
      ),
    );
  }

  void _selectPopularRoute(Map<String, dynamic> route) {
    final from = CitiesData.airports.firstWhere(
      (a) => a['code'] == route['from'],
      orElse: () => _fromAirport,
    );
    final to = CitiesData.airports.firstWhere(
      (a) => a['code'] == route['to'],
      orElse: () => _toAirport,
    );
    setState(() {
      _fromAirport = from;
      _toAirport = to;
    });
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
                    const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  'Where to fly?',
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
                  'Book your next adventure with ease.',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              // Auto-scrolling banner
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: CitiesData.airlineBanners.length,
                  onPageChanged: (i) => setState(() => _currentBanner = i),
                  itemBuilder: (context, index) {
                    return _buildBanner(CitiesData.airlineBanners[index]);
                  },
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  CitiesData.airlineBanners.length,
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

              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Trip Type
                      Row(
                        children: [
                          _tripTypeButton('One Way', !_isRoundTrip, () {
                            setState(() {
                              _isRoundTrip = false;
                              _returnDate = null;
                            });
                          }),
                          const SizedBox(width: 10),
                          _tripTypeButton('Round Trip', _isRoundTrip, () {
                            setState(() {
                              _isRoundTrip = true;
                            });
                          }),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // From Airport
                      _buildAirportField(
                        'From',
                        _fromAirport,
                        Icons.flight_takeoff,
                        () => _pickAirport(true),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          GestureDetector(
                            onTap: _swapAirports,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
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
                      _buildAirportField(
                        'To',
                        _toAirport,
                        Icons.flight_land,
                        () => _pickAirport(false),
                      ),
                      const SizedBox(height: 14),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Departure',
                              _departureDate,
                              () => _pickDate(true),
                            ),
                          ),
                          if (_isRoundTrip) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDateField(
                                'Return',
                                _returnDate ?? _departureDate.add(const Duration(days: 1)),
                                () => _pickDate(false),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Passengers & Class
                      Row(
                        children: [
                          Expanded(child: _buildPassengersField()),
                          const SizedBox(width: 10),
                          Expanded(child: _buildClassField()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _searchFlights,
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text(
                            'SEARCH FLIGHTS',
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

              // Popular Routes
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popular Destinations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: CitiesData.popularFlights.length,
                  itemBuilder: (context, index) {
                    return _buildRouteCard(CitiesData.popularFlights[index]);
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

  Widget _tripTypeButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
                errorBuilder: (_, __, ___) => Container(
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
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'AIRLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.flight, color: Colors.white, size: 18),
                    ],
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
                          color: Colors.white.withOpacity(0.85),
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

  Widget _buildAirportField(
    String label,
    Map<String, String> airport,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    airport['code']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airport['city']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        airport['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
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

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Passengers', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_passengers Adult${_passengers > 1 ? "s" : ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_passengers > 1) setState(() => _passengers--);
                },
                child: const Icon(Icons.remove, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_passengers < 9) setState(() => _passengers++);
                },
                child: const Icon(Icons.add, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: _classType,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
            items: _classes.map((c) => DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  const Icon(Icons.airline_seat_recline_normal, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _classType = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return GestureDetector(
      onTap: () => _selectPopularRoute(route),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  route['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            route['from'],
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.flight, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            route['to'],
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${route['fromCity']} → ${route['toCity']}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49B63),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        route['price'],
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

// AIRPORT PICKER
class _AirportPickerBottomSheet extends StatefulWidget {
  final String title;
  final String excludeCode;

  const _AirportPickerBottomSheet({
    required this.title,
    required this.excludeCode,
  });

  @override
  State<_AirportPickerBottomSheet> createState() => _AirportPickerBottomSheetState();
}

class _AirportPickerBottomSheetState extends State<_AirportPickerBottomSheet> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = CitiesData.airports
        .where((a) => a['code'] != widget.excludeCode)
        .toList();
  }

  void _filter(String query) {
    setState(() {
      _filtered = CitiesData.airports.where((a) {
        if (a['code'] == widget.excludeCode) return false;
        final q = query.toLowerCase();
        return a['city']!.toLowerCase().contains(q) ||
            a['code']!.toLowerCase().contains(q) ||
            a['name']!.toLowerCase().contains(q);
      }).toList();
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
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _filter,
                  decoration: InputDecoration(
                    hintText: 'Search airport...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
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
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final airport = _filtered[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      airport['code']!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(airport['city']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${airport['name']} • ${airport['country']}', style: const TextStyle(fontSize: 11)),
                  onTap: () => Navigator.pop(context, airport),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}