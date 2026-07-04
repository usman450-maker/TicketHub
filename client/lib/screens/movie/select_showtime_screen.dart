import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/booking_data.dart';
import '../../models/show_model.dart';
import '../../services/show_service.dart';
import '../../widgets/custom_snackbar.dart';

class SelectShowtimeScreen extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String moviePoster;
  final String movieBackdrop;

  const SelectShowtimeScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.moviePoster = '',
    this.movieBackdrop = '',
  });

  @override
  State<SelectShowtimeScreen> createState() => _SelectShowtimeScreenState();
}

class _SelectShowtimeScreenState extends State<SelectShowtimeScreen> {
  int? _selectedDate;
  int? _selectedVenue;
  Show? _selectedShow;
  List<Show> _availableShows = [];
  bool _isLoadingShows = false;

  // Auto-generate real dates for next 7 days
  List<Map<String, String>> _dates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  void _generateDates() {
    final now = DateTime.now();
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    _dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return {
        'day': days[date.weekday % 7],
        'date': date.day.toString(),
        'month': months[date.month - 1],
        'year': date.year.toString(),
        'full': '${months[date.month - 1]} ${date.day}, ${date.year}',
      };
    });
  }

  // ... rest of the code

  final List<Map<String, dynamic>> _venues = [
    {
      'name': 'Grand Luxe Theatre',
      'location': 'Upper East Side • 0.8 miles',
      'image': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      'tag': 'GOLD CLASS',
      'tagColor': const Color(0xFFC49B63),
      'features': ['DOLBY ATMOS', 'IMAX'],
    },
    {
      'name': 'The Zenith Atrium',
      'location': 'Financial District • 2.4 miles',
      'image': 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
      'tag': 'PREMIUM',
      'tagColor': AppColors.textDark,
      'features': ['4D EXPERIENCE', 'LASER'],
    },
    {
      'name': 'Cinema Star Plaza',
      'location': 'Downtown • 1.5 miles',
      'image': 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800',
      'tag': 'STANDARD',
      'tagColor': Colors.blueGrey,
      'features': ['4K UHD', '3D'],
    },
  ];

  bool get _allSelected =>
      _selectedDate != null && _selectedVenue != null && _selectedShow != null;

  Future<void> _loadShows() async {
    if (_selectedVenue == null || _selectedDate == null) return;

    setState(() {
      _isLoadingShows = true;
      _selectedShow = null;
      _availableShows = [];
    });

    final venue = _venues[_selectedVenue!];
    final date = _dates[_selectedDate!];

    final shows = await ShowService.generateShows(
      movieId: widget.movieId,
      movieTitle: widget.movieTitle,
      moviePoster: widget.moviePoster,
      venueName: venue['name'],
      venueLocation: venue['location'],
      showDate: date['full']!,
    );

    if (!mounted) return;

    setState(() {
      _availableShows = shows;
      _isLoadingShows = false;
    });

    if (shows.isEmpty) {
      CustomSnackbar.showError(
        context,
        'No shows available. All slots taken by other movies.',
      );
    }
  }

  void _onVenueSelected(int index) {
    setState(() {
      _selectedVenue = index;
      _selectedShow = null;
    });
    _loadShows();
  }

  void _onDateSelected(int index) {
    setState(() {
      _selectedDate = index;
      _selectedShow = null;
    });
    if (_selectedVenue != null) {
      _loadShows();
    }
  }

  void _proceedToSeatSelection() {
    if (!_allSelected) return;

    final venue = _venues[_selectedVenue!];

    final bookingData = BookingData(
      movieId: widget.movieId,
      movieTitle: widget.movieTitle,
      moviePoster: widget.moviePoster,
      movieBackdrop: widget.movieBackdrop,
      venueName: venue['name'],
      venueLocation: venue['location'],
      showDate: _selectedShow!.showDate,
      showTime: _selectedShow!.showTime,
      screenNumber: _selectedShow!.screenNumber,
      showId: _selectedShow!.id,
    );

    Navigator.pushNamed(
      context,
      RouteNames.seatSelection,
      arguments: bookingData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Select Show',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        widget.movieTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date
                   Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        '1. Choose Date',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      Row(
        children: [
          Text(
            '${_dates[0]['month']} ${_dates[0]['year']}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          if (_selectedDate != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 20),
          ],
        ],
      ),
    ],
  ),
),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _dates.length,
                        itemBuilder: (context, index) {
                          final selected = _selectedDate == index;
                          return GestureDetector(
                            onTap: () => _onDateSelected(index),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _dates[index]['day']!,
                                    style: TextStyle(
                                      color: selected ? Colors.white : AppColors.textGrey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dates[index]['date']!,
                                    style: TextStyle(
                                      color: selected ? Colors.white : AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
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

                    _sectionHeader('2. Select Venue', _selectedVenue != null),
                    const SizedBox(height: 14),
                    ...List.generate(_venues.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: _buildVenueCard(index),
                      );
                    }),

                    const SizedBox(height: 8),
                    _sectionHeader('3. Available Shows', _selectedShow != null),
                    const SizedBox(height: 14),

                    // Shows
                    if (_selectedVenue == null || _selectedDate == null)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Select venue and date to see shows',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                      )
                    else if (_isLoadingShows)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      )
                    else if (_availableShows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.movie_filter_outlined, color: AppColors.error, size: 40),
                              SizedBox(height: 10),
                              Text(
                                'No shows available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'All slots are booked by other movies.\nTry another venue or date.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _availableShows.map((show) => _buildShowCard(show)).toList(),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Next Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _allSelected ? _proceedToSeatSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('NEXT - SELECT SEATS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (done) const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildVenueCard(int index) {
    final venue = _venues[index];
    final selected = _selectedVenue == index;

    return GestureDetector(
      onTap: () => _onVenueSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
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
                    venue['image'],
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 140, color: AppColors.primaryLight),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue['name'],
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (venue['tagColor'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          venue['tag'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: venue['tagColor'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(venue['location'], style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowCard(Show show) {
    final selected = _selectedShow?.id == show.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedShow = show),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderGrey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time,
                color: selected ? Colors.white : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.showTime,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Screen ${show.screenNumber} • ${show.showDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}