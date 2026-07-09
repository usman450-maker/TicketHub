import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/routes/route_names.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../bus/bus_search_screen.dart';
import '../../flight/flight_search_screen.dart';
import '../../train/train_search_screen.dart';
import '../../sports/sports_home_screen.dart';
import '../../events/events_home_screen.dart';
import '../../parks/parks_home_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../widgets/category_item.dart';
import '../../../data/cities_data.dart';
import '../../../data/events_data.dart';
import '../../../data/parks_data.dart';
import '../../../data/sports_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String _userName = 'Guest';
  String? _profileImagePath;

  // Real data lists
  List<Map<String, dynamic>> _transportList = [];
  List<Map<String, dynamic>> _moviesList = [];
  List<Map<String, dynamic>> _eventsList = [];
  List<Map<String, dynamic>> _sportsList = [];
  List<Map<String, dynamic>> _parksList = [];

  bool _isLoading = true;

  // Search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

Future<void> _loadAllData() async {
  await Future.wait([
    _loadUser(),
    _loadTransport(),
    _loadMovies(),
    _loadEvents(),
    _loadSports(),
    _loadParks(),
  ]);
  if (mounted) {
    setState(() => _isLoading = false);

    // ✅ Debug prints - ye lagao
    print('Events loaded: ${_eventsList.length}');
    print('Sports loaded: ${_sportsList.length}');
    print('Parks loaded: ${_parksList.length}');

    // ✅ Image URLs check karo
    for (var s in _sportsList.take(2)) {
      print('SPORT: ${s['team1']} vs ${s['team2']} | IMAGE: ${s['image']}');
    }
    for (var p in _parksList.take(2)) {
      print('PARK: ${p['title']} | IMAGE: ${p['image']}');
    }
  }
}

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    final imagePath = await StorageService.getProfileImage();
    if (mounted && user != null) {
      setState(() {
        _userName = user['name']?.toString().split(' ').first ?? 'Guest';
        _profileImagePath = imagePath;
      });
    }
  }

Future<void> _loadTransport() async {
  try {
    final List<Map<String, dynamic>> allTransport = [];

    // ✅ Bus - Popular Routes as-is
    for (var route in CitiesData.popularRoutes) {
      allTransport.add({
        'from_location': route['from'],
        'to_location': route['to'],
        'transport_type': 'bus',
        'image_url': route['image'],
        'price': route['price'],
        'operator_name': '${route['from']} → ${route['to']}',
      });
    }

    // ✅ Train - Popular Routes as-is
    for (var route in CitiesData.popularTrainRoutes) {
      allTransport.add({
        'from_location': route['fromCity'],
        'to_location': route['toCity'],
        'transport_type': 'train',
        'image_url': route['image'],
        'price': route['price'],
        'operator_name': '${route['fromCity']} → ${route['toCity']}',
      });
    }

    // ✅ Flight - Popular Routes as-is
    for (var route in CitiesData.popularFlights) {
      allTransport.add({
        'from_location': route['fromCity'],
        'to_location': route['toCity'],
        'transport_type': 'flight',
        'image_url': route['image'],
        'price': route['price'],
        'operator_name': '${route['fromCity']} → ${route['toCity']}',
      });
    }

    // ✅ Shuffle and take 6
    allTransport.shuffle(Random());

    if (mounted) {
      setState(() => _transportList = allTransport.take(6).toList());
    }
  } catch (e) {
    print('Transport load error: $e');
  }
}

  Future<void> _loadMovies() async {
    try {
      final res = await ApiService.get(
        url: ApiEndpoints.tmdbNowPlaying(),
      );
      if (res['results'] != null) {
        final movies = (res['results'] as List)
            .where((m) => m['poster_path'] != null)
            .take(6)
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
        movies.shuffle(Random());
        if (mounted) setState(() => _moviesList = movies);
      }
    } catch (e) {
      print('Movies load error: $e');
    }
  }

Future<void> _loadEvents() async {
  try {
    final events = EventsData.events
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    events.shuffle(Random());
    if (mounted) setState(() => _eventsList = events.take(6).toList());
  } catch (e) {
    print('Events load error: $e');
  }
}

Future<void> _loadSports() async {
  try {
    final sports = SportsData.matches
        .map((s) => Map<String, dynamic>.from(s))
        .toList();
    sports.shuffle(Random());
    if (mounted) setState(() => _sportsList = sports.take(6).toList());
  } catch (e) {
    print('Sports load error: $e');
  }
}

Future<void> _loadParks() async {
  try {
    final parks = ParksData.parks
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    parks.shuffle(Random());
    if (mounted) setState(() => _parksList = parks.take(6).toList());
  } catch (e) {
    print('Parks load error: $e');
  }
}

Future<void> _performSearch(String query) async {
  if (query.trim().isEmpty) {
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
    return;
  }

  setState(() {
    _isSearching = true;
    _showSearchResults = true;
  });

  try {
    final results = <Map<String, dynamic>>[];
    final q = query.toLowerCase().trim();

    // ✅ 1. Search Movies (TMDB API)
    try {
      final movieRes = await ApiService.get(
        url:
            '${ApiEndpoints.tmdbBaseUrl}/search/movie?api_key=${ApiEndpoints.tmdbApiKey}&query=${Uri.encodeComponent(query)}',
      );
      if (movieRes['results'] != null) {
        for (var m in (movieRes['results'] as List).take(4)) {
          if (m['poster_path'] != null) {
            results.add({
              'type': 'movie',
              'id': m['id'],
              'title': m['title'] ?? '',
              'subtitle': m['release_date'] ?? '',
              'image':
                  '${ApiEndpoints.tmdbImageBase}${m['poster_path']}',
            });
          }
        }
      }
    } catch (e) {
      print('Movie search error: $e');
    }

    // ✅ 2. Search Transport (local data)
    for (var t in _transportList) {
      final name =
          (t['operator_name'] ?? '').toString().toLowerCase();
      final from =
          (t['from_location'] ?? '').toString().toLowerCase();
      final to =
          (t['to_location'] ?? '').toString().toLowerCase();
      final type =
          (t['transport_type'] ?? '').toString().toLowerCase();

      if (name.contains(q) ||
          from.contains(q) ||
          to.contains(q) ||
          type.contains(q)) {
        results.add({
          'type': 'transport',
          'data': t,
          'title': t['operator_name'] ?? 'Transport',
          'subtitle':
              '${t['from_location'] ?? ''} → ${t['to_location'] ?? ''}',
          'transport_type': t['transport_type'],
        });
      }
    }

    // ✅ 3. Search Events (local data)
    for (var e in _eventsList) {
      final title =
          (e['title'] ?? '').toString().toLowerCase();
      final venue =
          (e['venue'] ?? '').toString().toLowerCase();
      final city =
          (e['city'] ?? '').toString().toLowerCase();
      final category =
          (e['category'] ?? '').toString().toLowerCase();

      if (title.contains(q) ||
          venue.contains(q) ||
          city.contains(q) ||
          category.contains(q)) {
        results.add({
          'type': 'event',
          'data': e,
          'title': e['title'] ?? 'Event',
          'subtitle': '${e['venue'] ?? ''} • ${e['city'] ?? ''}',
          'image': (e['image'] ?? '').toString(),
        });
      }
    }

    // ✅ 4. Also search ALL events data (not just loaded 6)
    for (var e in EventsData.events) {
      final title =
          (e['title'] ?? '').toString().toLowerCase();
      final venue =
          (e['venue'] ?? '').toString().toLowerCase();
      final city =
          (e['city'] ?? '').toString().toLowerCase();
      final category =
          (e['category'] ?? '').toString().toLowerCase();

      // Skip if already in results
      final alreadyExists = results.any((r) =>
          r['type'] == 'event' &&
          r['title'] == (e['title'] ?? ''));

      if (!alreadyExists &&
          (title.contains(q) ||
              venue.contains(q) ||
              city.contains(q) ||
              category.contains(q))) {
        results.add({
          'type': 'event',
          'data': Map<String, dynamic>.from(e),
          'title': e['title'] ?? 'Event',
          'subtitle': '${e['venue'] ?? ''} • ${e['city'] ?? ''}',
          'image': (e['image'] ?? '').toString(),
        });
      }
    }

    // ✅ 5. Search Sports (ALL data)
    for (var s in SportsData.matches) {
      final team1 =
          (s['team1'] ?? '').toString().toLowerCase();
      final team2 =
          (s['team2'] ?? '').toString().toLowerCase();
      final sport =
          (s['sport'] ?? '').toString().toLowerCase();
      final venue =
          (s['venue'] ?? '').toString().toLowerCase();
      final city =
          (s['city'] ?? '').toString().toLowerCase();
      final league =
          (s['league'] ?? '').toString().toLowerCase();

      if (team1.contains(q) ||
          team2.contains(q) ||
          sport.contains(q) ||
          venue.contains(q) ||
          city.contains(q) ||
          league.contains(q)) {
        results.add({
          'type': 'sport',
          'data': Map<String, dynamic>.from(s),
          'title': '${s['team1']} vs ${s['team2']}',
          'subtitle': '${s['venue']} • ${s['city']}',
          'image': (s['image'] ?? '').toString(),
        });
      }
    }

    // ✅ 6. Search Parks (ALL data)
    for (var p in ParksData.parks) {
      final title =
          (p['title'] ?? '').toString().toLowerCase();
      final city =
          (p['city'] ?? '').toString().toLowerCase();
      final venue =
          (p['venue'] ?? '').toString().toLowerCase();
      final category =
          (p['category'] ?? '').toString().toLowerCase();

      if (title.contains(q) ||
          city.contains(q) ||
          venue.contains(q) ||
          category.contains(q)) {
        results.add({
          'type': 'park',
          'data': Map<String, dynamic>.from(p),
          'title': p['title'] ?? 'Park',
          'subtitle': '${p['venue'] ?? ''} • ${p['city'] ?? ''}',
          'image': (p['image'] ?? '').toString(),
        });
      }
    }

    // ✅ 7. Search ALL transport data
    for (var route in CitiesData.popularRoutes) {
      final from = (route['from'] ?? '').toString().toLowerCase();
      final to = (route['to'] ?? '').toString().toLowerCase();

      if (from.contains(q) || to.contains(q)) {
        final alreadyExists = results.any((r) =>
            r['type'] == 'transport' &&
            r['subtitle']?.contains(route['from'] ?? '') == true);

        if (!alreadyExists) {
          results.add({
            'type': 'transport',
            'title': '${route['from']} → ${route['to']}',
            'subtitle': route['price'] ?? 'Bus Route',
            'transport_type': 'bus',
          });
        }
      }
    }

    for (var route in CitiesData.popularTrainRoutes) {
      final from =
          (route['fromCity'] ?? '').toString().toLowerCase();
      final to =
          (route['toCity'] ?? '').toString().toLowerCase();

      if (from.contains(q) || to.contains(q)) {
        final alreadyExists = results.any((r) =>
            r['type'] == 'transport' &&
            r['title']?.contains(route['fromCity'] ?? '') ==
                true);

        if (!alreadyExists) {
          results.add({
            'type': 'transport',
            'title':
                '${route['fromCity']} → ${route['toCity']}',
            'subtitle': route['price'] ?? 'Train Route',
            'transport_type': 'train',
          });
        }
      }
    }

    for (var route in CitiesData.popularFlights) {
      final from =
          (route['fromCity'] ?? '').toString().toLowerCase();
      final to =
          (route['toCity'] ?? '').toString().toLowerCase();

      if (from.contains(q) || to.contains(q)) {
        final alreadyExists = results.any((r) =>
            r['type'] == 'transport' &&
            r['title']?.contains(route['fromCity'] ?? '') ==
                true);

        if (!alreadyExists) {
          results.add({
            'type': 'transport',
            'title':
                '${route['fromCity']} → ${route['toCity']}',
            'subtitle': route['price'] ?? 'Flight Route',
            'transport_type': 'flight',
          });
        }
      }
    }

    // ✅ 8. Category keywords
    if ('bus'.contains(q) ||
        q.contains('bus') ||
        q.contains('daewoo') ||
        q.contains('faisal')) {
      results.add({
        'type': 'transport',
        'title': 'Bus Tickets',
        'subtitle': 'Search and book bus tickets',
        'transport_type': 'bus',
        'is_category': true,
      });
    }
    if ('train'.contains(q) || q.contains('train') || q.contains('railway')) {
      results.add({
        'type': 'transport',
        'title': 'Train Tickets',
        'subtitle': 'Search and book train tickets',
        'transport_type': 'train',
        'is_category': true,
      });
    }
    if ('flight'.contains(q) ||
        q.contains('flight') ||
        q.contains('pia') ||
        q.contains('emirates')) {
      results.add({
        'type': 'transport',
        'title': 'Flight Tickets',
        'subtitle': 'Search and book flights',
        'transport_type': 'flight',
        'is_category': true,
      });
    }
    if ('event'.contains(q) ||
        q.contains('event') ||
        q.contains('concert') ||
        q.contains('comedy')) {
      results.add({
        'type': 'event',
        'title': 'Events',
        'subtitle': 'Browse all events',
        'is_category': true,
      });
    }
    if ('sport'.contains(q) ||
        q.contains('sport') ||
        q.contains('cricket') ||
        q.contains('football') ||
        q.contains('psl')) {
      results.add({
        'type': 'sport',
        'title': 'Sports Matches',
        'subtitle': 'Browse sports matches',
        'is_category': true,
      });
    }
    if ('park'.contains(q) ||
        q.contains('park') ||
        q.contains('joyland') ||
        q.contains('water')) {
      results.add({
        'type': 'park',
        'title': 'Parks & Attractions',
        'subtitle': 'Browse parks',
        'is_category': true,
      });
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

  // ✅ Transport icon helper
  IconData _getTransportIcon(String? type) {
    switch (type) {
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'flight':
        return Icons.flight;
      default:
        return Icons.directions;
    }
  }

  // ✅ Transport image helper
String _getTransportImage(String? type) {
  switch (type) {
    case 'bus':
      return 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800';
    case 'train':
      return 'https://images.unsplash.com/photo-1532105956626-9569c03602f6?w=800';
    case 'flight':
      return 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800';
    default:
      return 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800';
  }
}

    @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header - Avatar + Notification
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // ✅ Profile Avatar (left)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
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
                                color: AppColors.primary, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          builder: (_) =>
                              const NotificationsScreen()),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
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
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Greeting with real name
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

            // ✅ Search Bar
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
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText:
                              'Movies, buses, trains, flights, events...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.textGrey),
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        onSubmitted: _performSearch,
                        onChanged: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              _searchResults = [];
                              _showSearchResults = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Search Results
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
              )
            else if (_showSearchResults)
              _buildSearchResults()
            else ...[
              // ✅ Categories Grid
              const SizedBox(height: 12),
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
                          onTap: () => Navigator.pushNamed(
                              context, RouteNames.movies),
                        ),
                        CategoryItem(
                          icon: Icons.directions_bus_outlined,
                          label: 'Bus',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const BusSearchScreen()),
                          ),
                        ),
                        CategoryItem(
                          icon: Icons.train,
                          label: 'Train',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TrainSearchScreen()),
                          ),
                        ),
                        CategoryItem(
                          icon: Icons.flight,
                          label: 'Flights',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const FlightSearchScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CategoryItem(
                          icon: Icons.event_seat,
                          label: 'Events',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const EventsHomeScreen()),
                          ),
                        ),
                        CategoryItem(
                          icon: Icons.sports_soccer,
                          label: 'Sports',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SportsHomeScreen()),
                          ),
                        ),
                        CategoryItem(
                          icon: Icons.park_outlined,
                          label: 'Parks',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ParksHomeScreen()),
                          ),
                        ),
                        CategoryItem(
                            icon: Icons.apps, label: 'More'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Exclusive Travel - Real Data
              _buildSectionHeader('Exclusive Travel', () {
                // View all - show all transport
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BusSearchScreen()),
                );
              }),
              const SizedBox(height: 14),
              SizedBox(
                height: 240,
                child: _transportList.isEmpty
                    ? const Center(
                        child: Text('No transport data',
                            style:
                                TextStyle(color: AppColors.textGrey)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        itemCount: _transportList.length,
                        itemBuilder: (context, index) {
                          final t = _transportList[index];
                          final type =
                              t['transport_type']?.toString() ??
                                  'bus';
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 12),
                            child: _buildExclusiveCard(
                              image: t['image_url'] ??
                                  _getTransportImage(type),
                              tag: type.toUpperCase(),
                              title: t['operator_name'] ??
                                  'Transport',
                              subtitle:
                                  '${t['from_location'] ?? ''} → ${t['to_location'] ?? ''}',
                              onTap: () {
                                if (type == 'bus') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const BusSearchScreen()),
                                  );
                                } else if (type == 'train') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const TrainSearchScreen()),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const FlightSearchScreen()),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

              // ✅ Trending Now - Real Movies
              _buildSectionHeader('Trending Now', () {
                Navigator.pushNamed(context, RouteNames.movies);
              }),
              const SizedBox(height: 14),
              SizedBox(
                height: 280,
                child: _moviesList.isEmpty
                    ? const Center(
                        child: Text('No movies',
                            style:
                                TextStyle(color: AppColors.textGrey)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        itemCount: _moviesList.length,
                        itemBuilder: (context, index) {
                          final m = _moviesList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteNames.movieDetail,
                                arguments: m['id'],
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(
                                  right: 12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    child: Image.network(
                                      '${ApiEndpoints.tmdbImageBase}${m['poster_path']}',
                                      height: 220,
                                      width: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, _, _) => Container(
                                        height: 220,
                                        width: 160,
                                        color:
                                            AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    m['title'] ?? '',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color:
                                              Color(0xFFC49B63),
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        (m['vote_average'] ?? 0)
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color:
                                              AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

// ✅ Recommended - Events, Sports, Parks (2 ROWS)
_buildSectionHeader('Recommended for You', () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EventsHomeScreen()),
  );
}),
const SizedBox(height: 14),

// ✅ Row 1 - Events
SizedBox(
  height: 200,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      ..._eventsList.take(3).map(
        (e) => _buildRecommendCardWithTag(
          image: (e['image'] ?? '').toString(),
          title: (e['title'] ?? 'Event').toString(),
          subtitle: '${e['venue'] ?? ''} • ${e['city'] ?? ''}',
          tag: 'EVENTS',
          tagColor: const Color(0xFFEC407A),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventsHomeScreen()),
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 14),

// ✅ Row 2 - Sports & Parks
SizedBox(
  height: 200,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      ..._sportsList.take(2).map(
        (s) => _buildRecommendCardWithTag(
          image: (s['image'] ?? '').toString(),
          title: '${s['team1'] ?? ''} vs ${s['team2'] ?? ''}',
          subtitle: '${s['venue'] ?? ''} • ${s['city'] ?? ''}',
          tag: 'SPORTS',
          tagColor: const Color(0xFFF59E0B),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SportsHomeScreen()),
          ),
        ),
      ),
      ..._parksList.take(2).map(
        (p) => _buildRecommendCardWithTag(
          image: (p['image'] ?? '').toString(),
          title: (p['title'] ?? 'Park').toString(),
          subtitle: '${p['venue'] ?? ''} • ${p['city'] ?? ''}',
          tag: 'PARKS',
          tagColor: const Color(0xFF10B981),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ParksHomeScreen()),
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 28),

              // Exclusive Offers
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
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

              // Offer Card 1
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F3A2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                          borderRadius:
                              BorderRadius.circular(20),
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

              // Offer Card 2
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDCC9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                          borderRadius:
                              BorderRadius.circular(20),
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
              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
    );
  }

    // ✅ Section Header
  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'VIEW ALL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Search Results Widget
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off,
                  size: 50,
                  color: AppColors.primary.withOpacity(0.3)),
              const SizedBox(height: 12),
              const Text('No results found',
                  style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _showSearchResults = false);
                },
                child: const Text('Clear Search',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_searchResults.length} results found',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _showSearchResults = false);
                },
                child: const Text('Clear',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._searchResults.map((item) {
            IconData icon;
            Color color;
            switch (item['type']) {
              case 'movie':
                icon = Icons.movie_outlined;
                color = AppColors.primary;
                break;
              case 'transport':
                icon = Icons.directions_bus;
                color = const Color(0xFF3B82F6);
                break;
              case 'event':
                icon = Icons.event;
                color = const Color(0xFFEC407A);
                break;
              case 'sport':
                icon = Icons.sports_soccer;
                color = const Color(0xFFF59E0B);
                break;
              case 'park':
                icon = Icons.park;
                color = const Color(0xFF10B981);
                break;
              default:
                icon = Icons.search;
                color = AppColors.textGrey;
            }

            return GestureDetector(
              onTap: () {
                if (item['type'] == 'movie') {
                  Navigator.pushNamed(context, RouteNames.movieDetail,
                      arguments: item['id']);
                } else if (item['type'] == 'event') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EventsHomeScreen()),
                  );
                } else if (item['type'] == 'sport') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SportsHomeScreen()),
                  );
                } else if (item['type'] == 'park') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ParksHomeScreen()),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
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
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (item['type'] ?? '').toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ✅ Exclusive Card
Widget _buildExclusiveCard({
  required String image,
  required String tag,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
}) {
  // ✅ Fallback image if main image fails
  final fallbackImage = _getTransportImage(tag.toLowerCase());

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1F3A2E),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                // ✅ If main image fails, try fallback
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: fallbackImage,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1F3A2E),
                    child: Center(
                      child: Icon(
                        _getTransportIcon(tag.toLowerCase()),
                        color: Colors.white.withOpacity(0.5),
                        size: 40,
                      ),
                    ),
                  ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    ),
  );
}
  // ✅ Recommend Card (Horizontal)
Widget _buildRecommendCard({
  required String image,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: image,
                    height: 140,
                    width: 160,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 140,
                      width: 160,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 140,
                      width: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.primary.withOpacity(0.4),
                              size: 28),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 140,
                    width: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            color: AppColors.primary.withOpacity(0.4),
                            size: 28),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildRecommendCardWithTag({
  required String image,
  required String title,
  required String subtitle,
  required String tag,
  required Color tagColor,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // ✅ Image
                image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: image,
                        height: 140,
                        width: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 140,
                          width: 160,
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 140,
                          width: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tagColor.withOpacity(0.2),
                                tagColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  color: tagColor.withOpacity(0.5),
                                  size: 28),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: tagColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 140,
                        width: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              tagColor.withOpacity(0.2),
                              tagColor.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Icon(Icons.image_outlined,
                            color: tagColor.withOpacity(0.5),
                            size: 28),
                      ),

                // ✅ Tag badge (EVENTS, SPORTS, PARKS)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(6),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    ),
  );
}
}