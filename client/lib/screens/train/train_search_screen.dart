import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/cities_data.dart';
import 'train_list_screen.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  Map<String, String> _fromStation = CitiesData.trainStations[0];
  Map<String, String> _toStation = CitiesData.trainStations[1];
  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  int _passengers = 1;
  String _classType = 'Economy';

  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBanner = 0;

  final List<String> _classes = [
    'Economy',
    'AC Standard',
    'AC Business',
    'AC Sleeper',
    'Parlor Class',
  ];

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
        _currentBanner = (_currentBanner + 1) % CitiesData.trainBanners.length;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
    });
  }

  Future<void> _pickStation(bool isFrom) async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StationPickerBottomSheet(
        title: isFrom ? 'Departure Station' : 'Arrival Station',
        excludeCode: isFrom ? _toStation['code']! : _fromStation['code']!,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _fromStation = selected;
        } else {
          _toStation = selected;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _departureDate = picked);
  }

  void _searchTrains() {
    if (_fromStation['code'] == _toStation['code']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To stations cannot be same')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainListScreen(
          fromStation: _fromStation,
          toStation: _toStation,
          date: _formatDate(_departureDate),
          passengers: _passengers,
          classType: _classType,
        ),
      ),
    );
  }

  void _selectPopularRoute(Map<String, dynamic> route) {
    final from = CitiesData.trainStations.firstWhere(
      (s) => s['code'] == route['from'],
      orElse: () => _fromStation,
    );
    final to = CitiesData.trainStations.firstWhere(
      (s) => s['code'] == route['to'],
      orElse: () => _toStation,
    );
    setState(() {
      _fromStation = from;
      _toStation = to;
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
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  'Where to travel?',
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
                  'Book your train journey with comfort.',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              // Banner
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: CitiesData.trainBanners.length,
                  onPageChanged: (i) => setState(() => _currentBanner = i),
                  itemBuilder: (context, index) {
                    return _buildBanner(CitiesData.trainBanners[index]);
                  },
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  CitiesData.trainBanners.length,
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStationField(
                        'From', _fromStation, Icons.train,
                        () => _pickStation(true)),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          GestureDetector(
                            onTap: _swapStations,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.swap_vert,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      _buildStationField(
                        'To', _toStation, Icons.location_on,
                        () => _pickStation(false)),
                      const SizedBox(height: 14),
                      _buildDateField(),
                      const SizedBox(height: 14),
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
                          onPressed: _searchTrains,
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text(
                            'SEARCH TRAINS',
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
                  'Popular Train Routes',
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
                  itemCount: CitiesData.popularTrainRoutes.length,
                  itemBuilder: (context, index) {
                    return _buildRouteCard(CitiesData.popularTrainRoutes[index]);
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'TRAIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.train, color: Colors.white, size: 18),
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

  Widget _buildStationField(
    String label,
    Map<String, String> station,
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
                    station['code']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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
                        station['city']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        station['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departure Date', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
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
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_departureDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
              child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
                  errorBuilder: (_, _, _) => Container(color: AppColors.primaryLight),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
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
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            route['from'],
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.train, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
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

// STATION PICKER
class _StationPickerBottomSheet extends StatefulWidget {
  final String title;
  final String excludeCode;

  const _StationPickerBottomSheet({
    required this.title,
    required this.excludeCode,
  });

  @override
  State<_StationPickerBottomSheet> createState() => _StationPickerBottomSheetState();
}

class _StationPickerBottomSheetState extends State<_StationPickerBottomSheet> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = CitiesData.trainStations
        .where((s) => s['code'] != widget.excludeCode)
        .toList();
  }

  void _filter(String query) {
    setState(() {
      _filtered = CitiesData.trainStations.where((s) {
        if (s['code'] == widget.excludeCode) return false;
        final q = query.toLowerCase();
        return s['city']!.toLowerCase().contains(q) ||
            s['code']!.toLowerCase().contains(q) ||
            s['name']!.toLowerCase().contains(q);
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
                    hintText: 'Search station...',
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
                final station = _filtered[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      station['code']!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(station['city']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(station['name']!, style: const TextStyle(fontSize: 11)),
                  onTap: () => Navigator.pop(context, station),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}