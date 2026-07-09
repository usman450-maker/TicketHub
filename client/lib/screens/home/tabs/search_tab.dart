import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/routes/route_names.dart';
import '../../../data/cities_data.dart';
import '../../../data/events_data.dart';
import '../../../data/sports_data.dart';
import '../../../data/parks_data.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../bus/bus_search_screen.dart';
import '../../flight/flight_search_screen.dart';
import '../../train/train_search_screen.dart';
import '../../events/events_home_screen.dart';
import '../../sports/sports_home_screen.dart';
import '../../parks/parks_home_screen.dart';
import '../../notifications/notifications_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _profileImagePath;
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _popularSuggestions = [];

  final List<String> _filters = [
    'All',
    'Movies',
    'Bus',
    'Train',
    'Flights',
    'Events',
    'Sports',
    'Parks',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _generatePopularSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final imagePath = await StorageService.getProfileImage();
    if (mounted) {
      setState(() => _profileImagePath = imagePath);
    }
  }

void _generatePopularSuggestions() {
  final random = Random();
  final allSuggestions = <Map<String, dynamic>>[];

  // Movies suggestions
  final movieNames = [
    'Avengers', 'Batman', 'Spider-Man', 'Inception',
    'Interstellar', 'The Dark Knight', 'Oppenheimer',
    'Dune', 'Avatar', 'Titanic',
  ];
  for (var name in movieNames) {
    allSuggestions.add({
      'title': name,
      'type': 'movie',
      'icon': Icons.movie_outlined,
      'color': AppColors.primary,
    });
  }

  // Transport suggestions
  for (var route in CitiesData.popularRoutes) {
    allSuggestions.add({
      'title': '${route['from']} → ${route['to']}',
      'type': 'bus',
      'icon': Icons.directions_bus,
      'color': AppColors.primary,
    });
  }
  for (var route in CitiesData.popularTrainRoutes) {
    allSuggestions.add({
      'title': '${route['fromCity']} → ${route['toCity']}',
      'type': 'train',
      'icon': Icons.train,
      'color': AppColors.primary,
    });
  }
  for (var route in CitiesData.popularFlights) {
    allSuggestions.add({
      'title': '${route['fromCity']} → ${route['toCity']}',
      'type': 'flight',
      'icon': Icons.flight,
      'color': AppColors.primary,
    });
  }

  // Events suggestions
  for (var e in EventsData.events) {
    allSuggestions.add({
      'title': e['title'] ?? '',
      'type': 'event',
      'icon': Icons.event,
      'color': AppColors.primary,
    });
  }

  // Sports suggestions
  for (var s in SportsData.matches) {
    allSuggestions.add({
      'title': '${s['team1']} vs ${s['team2']}',
      'type': 'sport',
      'icon': Icons.sports_soccer,
      'color': AppColors.primary,
    });
  }

  // Parks suggestions
  for (var p in ParksData.parks) {
    allSuggestions.add({
      'title': p['title'] ?? '',
      'type': 'park',
      'icon': Icons.park,
      'color': AppColors.primary,
    });
  }

  allSuggestions.shuffle(random);
  setState(() => _popularSuggestions = allSuggestions.take(8).toList());
}

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    // Save to recent
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = <Map<String, dynamic>>[];
      final q = query.toLowerCase().trim();
      final filter = _selectedFilter;

      // ✅ 1. Movies
      if (filter == 'All' || filter == 'Movies') {
        try {
          final movieRes = await ApiService.get(
            url:
                '${ApiEndpoints.tmdbBaseUrl}/search/movie?api_key=${ApiEndpoints.tmdbApiKey}&query=${Uri.encodeComponent(query)}',
          );
          if (movieRes['results'] != null) {
            for (var m in (movieRes['results'] as List).take(5)) {
              if (m['poster_path'] != null) {
                results.add({
                  'type': 'movie',
                  'id': m['id'],
                  'title': m['title'] ?? '',
                  'subtitle': m['release_date'] ?? '',
                  'image':
                      '${ApiEndpoints.tmdbImageBase}${m['poster_path']}',
                  'icon': Icons.movie_outlined,
                  'color': AppColors.primary,
                });
              }
            }
          }
        } catch (e) {
          print('Movie search error: $e');
        }
      }

      // ✅ 2. Bus
      if (filter == 'All' || filter == 'Bus') {
        for (var route in CitiesData.popularRoutes) {
          final from = (route['from'] ?? '').toString().toLowerCase();
          final to = (route['to'] ?? '').toString().toLowerCase();
          if (from.contains(q) || to.contains(q) || 'bus'.contains(q)) {
            results.add({
              'type': 'bus',
              'title': '${route['from']} → ${route['to']}',
              'subtitle': route['price'] ?? '',
              'image': route['image'] ?? '',
              'icon': Icons.directions_bus,
              'color': const Color(0xFF3B82F6),
            });
          }
        }
        for (var b in CitiesData.busBanners) {
          final name = (b['name'] ?? '').toString().toLowerCase();
          if (name.contains(q)) {
            results.add({
              'type': 'bus',
              'title': b['name'] ?? '',
              'subtitle': b['tagline'] ?? 'Bus Service',
              'image': b['image'] ?? '',
              'icon': Icons.directions_bus,
              'color': const Color(0xFF3B82F6),
            });
          }
        }
      }

      // ✅ 3. Train
      if (filter == 'All' || filter == 'Train') {
        for (var route in CitiesData.popularTrainRoutes) {
          final from =
              (route['fromCity'] ?? '').toString().toLowerCase();
          final to =
              (route['toCity'] ?? '').toString().toLowerCase();
          if (from.contains(q) || to.contains(q) || 'train'.contains(q)) {
            results.add({
              'type': 'train',
              'title': '${route['fromCity']} → ${route['toCity']}',
              'subtitle': route['price'] ?? '',
              'image': route['image'] ?? '',
              'icon': Icons.train,
              'color': const Color(0xFF8B5CF6),
            });
          }
        }
        for (var t in CitiesData.trainBanners) {
          final name = (t['name'] ?? '').toString().toLowerCase();
          if (name.contains(q)) {
            results.add({
              'type': 'train',
              'title': t['name'] ?? '',
              'subtitle': t['tagline'] ?? 'Train Service',
              'image': t['image'] ?? '',
              'icon': Icons.train,
              'color': const Color(0xFF8B5CF6),
            });
          }
        }
      }

      // ✅ 4. Flights
      if (filter == 'All' || filter == 'Flights') {
        for (var route in CitiesData.popularFlights) {
          final from =
              (route['fromCity'] ?? '').toString().toLowerCase();
          final to =
              (route['toCity'] ?? '').toString().toLowerCase();
          if (from.contains(q) ||
              to.contains(q) ||
              'flight'.contains(q)) {
            results.add({
              'type': 'flight',
              'title': '${route['fromCity']} → ${route['toCity']}',
              'subtitle': route['price'] ?? '',
              'image': route['image'] ?? '',
              'icon': Icons.flight,
              'color': const Color(0xFF06B6D4),
            });
          }
        }
        for (var a in CitiesData.airlineBanners) {
          final name = (a['name'] ?? '').toString().toLowerCase();
          if (name.contains(q)) {
            results.add({
              'type': 'flight',
              'title': a['name'] ?? '',
              'subtitle': a['tagline'] ?? 'Airline',
              'image': a['image'] ?? '',
              'icon': Icons.flight,
              'color': const Color(0xFF06B6D4),
            });
          }
        }
      }

      // ✅ 5. Events
      if (filter == 'All' || filter == 'Events') {
        for (var e in EventsData.events) {
          final title =
              (e['title'] ?? '').toString().toLowerCase();
          final venue =
              (e['venue'] ?? '').toString().toLowerCase();
          final city = (e['city'] ?? '').toString().toLowerCase();
          final category =
              (e['category'] ?? '').toString().toLowerCase();

          if (title.contains(q) ||
              venue.contains(q) ||
              city.contains(q) ||
              category.contains(q) ||
              'event'.contains(q)) {
            results.add({
              'type': 'event',
              'data': Map<String, dynamic>.from(e),
              'title': e['title'] ?? 'Event',
              'subtitle': '${e['venue'] ?? ''} • ${e['city'] ?? ''}',
              'image': (e['image'] ?? '').toString(),
              'icon': Icons.event,
              'color': const Color(0xFFEC407A),
            });
          }
        }
      }

      // ✅ 6. Sports
      if (filter == 'All' || filter == 'Sports') {
        for (var s in SportsData.matches) {
          final team1 =
              (s['team1'] ?? '').toString().toLowerCase();
          final team2 =
              (s['team2'] ?? '').toString().toLowerCase();
          final sport =
              (s['sport'] ?? '').toString().toLowerCase();
          final venue =
              (s['venue'] ?? '').toString().toLowerCase();
          final league =
              (s['league'] ?? '').toString().toLowerCase();

          if (team1.contains(q) ||
              team2.contains(q) ||
              sport.contains(q) ||
              venue.contains(q) ||
              league.contains(q) ||
              'sport'.contains(q)) {
            results.add({
              'type': 'sport',
              'data': Map<String, dynamic>.from(s),
              'title': '${s['team1']} vs ${s['team2']}',
              'subtitle': '${s['venue']} • ${s['city']}',
              'image': (s['image'] ?? '').toString(),
              'icon': Icons.sports_soccer,
              'color': const Color(0xFFF59E0B),
            });
          }
        }
      }

      // ✅ 7. Parks
      if (filter == 'All' || filter == 'Parks') {
        for (var p in ParksData.parks) {
          final title =
              (p['title'] ?? '').toString().toLowerCase();
          final city = (p['city'] ?? '').toString().toLowerCase();
          final venue =
              (p['venue'] ?? '').toString().toLowerCase();
          final category =
              (p['category'] ?? '').toString().toLowerCase();

          if (title.contains(q) ||
              city.contains(q) ||
              venue.contains(q) ||
              category.contains(q) ||
              'park'.contains(q)) {
            results.add({
              'type': 'park',
              'data': Map<String, dynamic>.from(p),
              'title': p['title'] ?? 'Park',
              'subtitle': '${p['venue'] ?? ''} • ${p['city'] ?? ''}',
              'image': (p['image'] ?? '').toString(),
              'icon': Icons.park,
              'color': const Color(0xFF10B981),
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _searchByFilter(String filter) {
    setState(() => _selectedFilter = filter);

    if (filter == 'All') {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
        _searchController.clear();
      });
      return;
    }

    // ✅ Category pe click kare toh uska data show ho
    switch (filter) {
      case 'Movies':
        _searchController.text = 'Popular Movies';
        _search('a'); // broad search
        break;
      case 'Bus':
        _showCategoryResults('bus', CitiesData.popularRoutes.map((r) => {
              'type': 'bus',
              'title': '${r['from']} → ${r['to']}',
              'subtitle': r['price'] ?? '',
              'image': r['image'] ?? '',
              'icon': Icons.directions_bus,
              'color': const Color(0xFF3B82F6),
            }).toList());
        break;
      case 'Train':
        _showCategoryResults(
            'train',
            CitiesData.popularTrainRoutes.map((r) => {
                  'type': 'train',
                  'title': '${r['fromCity']} → ${r['toCity']}',
                  'subtitle': r['price'] ?? '',
                  'image': r['image'] ?? '',
                  'icon': Icons.train,
                  'color': const Color(0xFF8B5CF6),
                }).toList());
        break;
      case 'Flights':
        _showCategoryResults(
            'flight',
            CitiesData.popularFlights.map((r) => {
                  'type': 'flight',
                  'title': '${r['fromCity']} → ${r['toCity']}',
                  'subtitle': r['price'] ?? '',
                  'image': r['image'] ?? '',
                  'icon': Icons.flight,
                  'color': const Color(0xFF06B6D4),
                }).toList());
        break;
      case 'Events':
        _showCategoryResults(
            'event',
            EventsData.events.map((e) => {
                  'type': 'event',
                  'data': Map<String, dynamic>.from(e),
                  'title': e['title'] ?? 'Event',
                  'subtitle': '${e['venue'] ?? ''} • ${e['city'] ?? ''}',
                  'image': (e['image'] ?? '').toString(),
                  'icon': Icons.event,
                  'color': const Color(0xFFEC407A),
                }).toList());
        break;
      case 'Sports':
        _showCategoryResults(
            'sport',
            SportsData.matches.map((s) => {
                  'type': 'sport',
                  'data': Map<String, dynamic>.from(s),
                  'title': '${s['team1']} vs ${s['team2']}',
                  'subtitle': '${s['venue']} • ${s['city']}',
                  'image': (s['image'] ?? '').toString(),
                  'icon': Icons.sports_soccer,
                  'color': const Color(0xFFF59E0B),
                }).toList());
        break;
      case 'Parks':
        _showCategoryResults(
            'park',
            ParksData.parks.map((p) => {
                  'type': 'park',
                  'data': Map<String, dynamic>.from(p),
                  'title': p['title'] ?? 'Park',
                  'subtitle': '${p['venue'] ?? ''} • ${p['city'] ?? ''}',
                  'image': (p['image'] ?? '').toString(),
                  'icon': Icons.park,
                  'color': const Color(0xFF10B981),
                }).toList());
        break;
    }
  }

  void _showCategoryResults(
      String type, List<Map<String, dynamic>> items) {
    setState(() {
      _searchResults = items;
      _hasSearched = true;
      _isSearching = false;
      _searchController.text = _selectedFilter;
    });
  }

  void _navigateToResult(Map<String, dynamic> item) {
    final type = item['type'] as String;

    switch (type) {
      case 'movie':
        if (item['id'] != null) {
          Navigator.pushNamed(context, RouteNames.movieDetail,
              arguments: item['id']);
        } else {
          Navigator.pushNamed(context, RouteNames.movies);
        }
        break;
      case 'bus':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BusSearchScreen()));
        break;
      case 'train':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TrainSearchScreen()));
        break;
      case 'flight':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FlightSearchScreen()));
        break;
      case 'event':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EventsHomeScreen()));
        break;
      case 'sport':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SportsHomeScreen()));
        break;
      case 'park':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ParksHomeScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header - Avatar left, Notification right
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // ✅ Profile Avatar (left)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _profileImagePath != null &&
                            File(_profileImagePath!).existsSync()
                        ? Image.file(
                            File(_profileImagePath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person,
                            color: AppColors.primary, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'TicketHub',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // ✅ Notification icon (right)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ Search Bar
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText:
                            'Movies, buses, trains, events, parks...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      onSubmitted: _search,
                      onChanged: (val) {
                        if (val.isEmpty) {
                          setState(() {
                            _searchResults = [];
                            _hasSearched = false;
                          });
                        }
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _hasSearched = false;
                          _selectedFilter = 'All';
                        });
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.textGrey, size: 20),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_searchController.text.isNotEmpty) {
                        _search(_searchController.text);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isSelected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => _searchByFilter(f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1F3A2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Content
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : _hasSearched
                    ? _buildSearchResults()
                    : _buildDefaultContent(),
          ),
        ],
      ),
    );
  }

  // ✅ Search Results
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 60,
                color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No results found',
                style: TextStyle(
                    fontSize: 16, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _hasSearched = false;
                  _selectedFilter = 'All';
                });
              },
              child: const Text('Clear Search',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final typeColor =
            item['color'] as Color? ?? AppColors.primary;
        final typeIcon =
            item['icon'] as IconData? ?? Icons.search;

        return GestureDetector(
          onTap: () => _navigateToResult(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                // Image or Icon
                if (item['image'] != null &&
                    item['image'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: item['image'],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            Icon(typeIcon, color: typeColor, size: 24),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(typeIcon, color: typeColor, size: 24),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (item['type'] ?? '').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Default Content
  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Searches',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _recentSearches.clear()),
                    child: const Text('Clear All',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...(_recentSearches.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.text = s;
                      _search(s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history,
                              size: 16, color: AppColors.textGrey),
                          const SizedBox(width: 8),
                          Text(s,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(
                                () => _recentSearches.remove(s)),
                            child: const Icon(Icons.close,
                                size: 16,
                                color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))),
            const SizedBox(height: 20),
          ],

          // ✅ Popular Searches
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_fire_department,
                          color: Color(0xFFC49B63), size: 22),
                      SizedBox(width: 8),
                      Text('Popular Searches',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _popularSearchItem(
                      'Movies', Icons.movie_outlined, () {
                    _searchByFilter('Movies');
                  }),
                  _popularSearchItem(
                      'Bus Tickets', Icons.directions_bus, () {
                    _searchByFilter('Bus');
                  }),
                  _popularSearchItem(
                      'Train Tickets', Icons.train, () {
                    _searchByFilter('Train');
                  }),
                  _popularSearchItem(
                      'Flights', Icons.flight, () {
                    _searchByFilter('Flights');
                  }),
                  _popularSearchItem(
                      'Events', Icons.event, () {
                    _searchByFilter('Events');
                  }),
                  _popularSearchItem(
                      'Sports', Icons.sports_soccer, () {
                    _searchByFilter('Sports');
                  }),
                  _popularSearchItem(
                      'Parks', Icons.park, () {
                    _searchByFilter('Parks');
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ✅ Popular Suggestions (Random - changes every restart)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Popular Suggestions',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSuggestions.map((s) {
                final color = s['color'] as Color? ??
                    AppColors.primary;
                final icon = s['icon'] as IconData? ??
                    Icons.search;

                return GestureDetector(
                  onTap: () {
                    _searchController.text =
                        s['title']?.toString() ?? '';
                    _search(s['title']?.toString() ?? '');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          s['title']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ✅ TicketHub Pass Card
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
                  const Text('TicketHub Pass',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock early access to premium events and exclusive lounge entries.',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4),
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
                      child: Text('Explore Benefits',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _popularSearchItem(
      String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppColors.textGrey, size: 20),
          ],
        ),
      ),
    );
  }
}