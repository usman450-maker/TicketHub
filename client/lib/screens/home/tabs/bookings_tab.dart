import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_data.dart';
import '../../../models/transport_booking.dart';
import '../../../services/booking_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/ticket_save_service.dart';
import '../../../services/transport_service.dart';
import '../../../services/transport_ticket_save_service.dart';
import '../../../widgets/custom_snackbar.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _movieBookings = [];
  List<Map<String, dynamic>> _busBookings = [];
  List<Map<String, dynamic>> _flightBookings = [];
  List<Map<String, dynamic>> _trainBookings = [];
  List<Map<String, dynamic>> _sportsBookings = [];
  List<Map<String, dynamic>> _eventBookings = [];
  bool _isLoading = true;
  String _userName = 'Guest';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await StorageService.getUser();
    if (user != null) {
      _userName = user['name'] ?? 'Guest';
      _userEmail = user['email'] ?? '';
    }

    // Load MOVIE bookings
    try {
      final movieRes = await BookingService.getMyBookings();
      if (movieRes['success'] == true && movieRes['bookings'] != null) {
        _movieBookings = List<Map<String, dynamic>>.from(movieRes['bookings']);
      }
    } catch (e) {
      print('Movie error: $e');
    }

    // Load TRANSPORT bookings (bus, flight, train, sports, event)
    try {
      final transportRes = await TransportService.getMyBookings();
      if (transportRes['success'] == true && transportRes['bookings'] != null) {
        final all = List<Map<String, dynamic>>.from(transportRes['bookings']);

        _busBookings = all.where((b) =>
            b['transport_type']?.toString().toLowerCase() == 'bus').toList();
        _flightBookings = all.where((b) =>
            b['transport_type']?.toString().toLowerCase() == 'flight').toList();
        _trainBookings = all.where((b) =>
            b['transport_type']?.toString().toLowerCase() == 'train').toList();
        _sportsBookings = all.where((b) =>
            b['transport_type']?.toString().toLowerCase() == 'sports').toList();
        _eventBookings = all.where((b) =>
            b['transport_type']?.toString().toLowerCase() == 'event').toList();
      }
    } catch (e) {
      print('Transport error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveMovieTicket(Map<String, dynamic> booking) async {
    List<dynamic> rawSeats = [];
    if (booking['seats'] != null) {
      if (booking['seats'] is List) {
        rawSeats = booking['seats'];
      } else if (booking['seats'] is String) {
        rawSeats = booking['seats'].toString()
            .replaceAll('{', '').replaceAll('}', '')
            .split(',').map((s) => s.trim()).toList();
      }
    }

    final seats = rawSeats.map((s) => SeatSelection(
      id: s.toString(),
      tier: _getMovieTier(s.toString()),
      price: _getMoviePrice(s.toString()),
    )).toList();

    final bookingData = BookingData(
      movieId: booking['movie_id'] ?? 0,
      movieTitle: booking['movie_title']?.toString() ?? '',
      moviePoster: booking['movie_poster']?.toString() ?? '',
      movieBackdrop: '',
      venueName: booking['venue_name']?.toString() ?? '',
      venueLocation: booking['venue_location']?.toString() ?? '',
      showDate: booking['show_date']?.toString() ?? '',
      showTime: booking['show_time']?.toString() ?? '',
      screenNumber: booking['screen_number'] ?? 1,
      selectedSeats: seats,
    );

    final success = await TicketSaveService.saveTicketToGallery(
      context: context,
      booking: bookingData,
      orderNumber: booking['order_number']?.toString() ?? '',
      userName: _userName,
      userEmail: _userEmail,
    );

    if (!mounted) return;
    CustomSnackbar.showSuccess(context, success ? 'Ticket saved!' : 'Failed');
  }

  Future<void> _saveTransportTicket(
    Map<String, dynamic> booking,
    String seatId,
    Map<String, dynamic> passengerData,
  ) async {
    final passenger = Passenger(
      fullName: passengerData['fullName']?.toString() ?? '',
      idNumber: passengerData['idNumber']?.toString() ?? '',
      gender: passengerData['gender']?.toString() ?? 'Male',
      age: passengerData['age'] is int
          ? passengerData['age']
          : int.tryParse(passengerData['age']?.toString() ?? '0') ?? 0,
      nationality: passengerData['nationality']?.toString() ?? '',
      email: passengerData['email']?.toString() ?? '',
      phone: passengerData['phone']?.toString() ?? '',
    );

    List<String> seatList = _parseSeats(booking['seat_numbers']);
    List<Map<String, dynamic>> passengers = _parsePassengers(booking['passenger_details']);

    final allPassengers = passengers.map((p) => Passenger(
      fullName: p['fullName']?.toString() ?? '',
      idNumber: p['idNumber']?.toString() ?? '',
      gender: p['gender']?.toString() ?? 'Male',
      age: p['age'] is int ? p['age'] : int.tryParse(p['age']?.toString() ?? '0') ?? 0,
      nationality: p['nationality']?.toString() ?? '',
      email: p['email']?.toString() ?? '',
      phone: p['phone']?.toString() ?? '',
    )).toList();

    final total = double.tryParse(booking['total_amount']?.toString() ?? '0') ?? 0;

    final transportBooking = TransportBooking(
      transportType: booking['transport_type']?.toString() ?? 'bus',
      operatorName: booking['operator_name']?.toString() ?? '',
      operatorNumber: booking['operator_number']?.toString() ?? '',
      fromLocation: booking['from_location']?.toString() ?? '',
      toLocation: booking['to_location']?.toString() ?? '',
      departureDate: booking['departure_date']?.toString() ?? '',
      departureTime: booking['departure_time']?.toString() ?? '',
      arrivalTime: booking['arrival_time']?.toString(),
      duration: booking['duration']?.toString(),
      classType: booking['class_type']?.toString(),
      seatNumbers: seatList,
      passengers: allPassengers.isEmpty ? [passenger] : allPassengers,
      pricePerPassenger: total / (allPassengers.isEmpty ? 1 : allPassengers.length),
    );

    final success = await TransportTicketSaveService.saveTicketToGallery(
      context: context,
      booking: transportBooking,
      orderNumber: booking['order_number']?.toString() ?? '',
      passenger: passenger,
      seatId: seatId,
    );

    if (!mounted) return;
    CustomSnackbar.showSuccess(context,
        success ? 'Ticket saved for ${passenger.fullName}!' : 'Failed');
  }

  List<String> _parseSeats(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List) return List<String>.from(raw.map((s) => s.toString()));
      if (raw is String) {
        return raw.replaceAll('{', '').replaceAll('}', '')
            .split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    } catch (e) {}
    return [];
  }

  List<Map<String, dynamic>> _parsePassengers(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List) {
        return raw.map((p) {
          if (p is Map) return Map<String, dynamic>.from(p);
          return <String, dynamic>{};
        }).toList();
      }
    } catch (e) {}
    return [];
  }

  String _getMovieTier(String s) {
    if (s.isEmpty) return 'STANDARD';
    final r = s[0];
    if (['A', 'B'].contains(r)) return 'STANDARD';
    if (['C', 'D', 'E'].contains(r)) return 'PREMIUM';
    return 'GOLD CLASS';
  }

  double _getMoviePrice(String s) {
    final t = _getMovieTier(s);
    if (t == 'STANDARD') return 15;
    if (t == 'PREMIUM') return 25;
    return 45;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: const [
                Icon(Icons.confirmation_number_outlined,
                    color: AppColors.primary, size: 26),
                SizedBox(width: 10),
                Text('My Bookings',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
              ],
            ),
          ),

          // ==========================
          // BIGGER TABS
          // ==========================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorPadding: const EdgeInsets.all(5),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              tabs: [
                _buildTab(Icons.movie, 'Movies', _movieBookings.length),
                _buildTab(Icons.directions_bus, 'Buses', _busBookings.length),
                _buildTab(Icons.flight, 'Flights', _flightBookings.length),
                _buildTab(Icons.train, 'Trains', _trainBookings.length),
                _buildTab(Icons.sports, 'Sports', _sportsBookings.length),
                _buildTab(Icons.celebration, 'Events', _eventBookings.length),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListTab(_movieBookings, Icons.movie, 'movie'),
                      _buildListTab(_busBookings, Icons.directions_bus, 'transport'),
                      _buildListTab(_flightBookings, Icons.flight, 'transport'),
                      _buildListTab(_trainBookings, Icons.train, 'transport'),
                      _buildListTab(_sportsBookings, Icons.sports, 'transport'),
                      _buildListTab(_eventBookings, Icons.celebration, 'transport'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int count) {
    return Tab(
      height: 65,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 3),
            Text('$label ($count)', style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildListTab(
      List<Map<String, dynamic>> bookings, IconData icon, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No bookings yet',
                style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          if (type == 'movie') {
            return _buildMovieCard(bookings[index]);
          }
          return _buildTransportCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> booking) {
    final seats = _parseSeats(booking['seats']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (booking['movie_poster'] != null &&
                  booking['movie_poster'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    booking['movie_poster'].toString(),
                    width: 60, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60, height: 90, color: AppColors.primaryLight,
                      child: const Icon(Icons.movie, color: Colors.white)),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['movie_title']?.toString() ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _tiny(Icons.calendar_today, booking['show_date']?.toString() ?? ''),
                    _tiny(Icons.access_time, booking['show_time']?.toString() ?? ''),
                    _tiny(Icons.location_on, booking['venue_name']?.toString() ?? ''),
                    _tiny(Icons.tv, 'Screen ${booking['screen_number'] ?? 1}'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.event_seat, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(child: Text('Seats: ${seats.join(", ")}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              Text(
                '\$${double.tryParse(booking['total_amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _saveMovieTicket(booking),
              icon: const Icon(Icons.download, size: 16, color: Colors.white),
              label: const Text('Save Movie Ticket',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(Map<String, dynamic> booking) {
    final seats = _parseSeats(booking['seat_numbers']);
    final passengers = _parsePassengers(booking['passenger_details']);
    final type = booking['transport_type']?.toString().toLowerCase() ?? '';
    final isSportsOrEvent = type == 'sports' || type == 'event';

    IconData typeIcon;
    String typeLabel;
    switch (type) {
      case 'bus': typeIcon = Icons.directions_bus; typeLabel = 'BUS'; break;
      case 'flight': typeIcon = Icons.flight; typeLabel = 'FLIGHT'; break;
      case 'train': typeIcon = Icons.train; typeLabel = 'TRAIN'; break;
      case 'sports': typeIcon = Icons.stadium; typeLabel = 'SPORTS'; break;
      case 'event': typeIcon = Icons.celebration; typeLabel = 'EVENT'; break;
      default: typeIcon = Icons.confirmation_number; typeLabel = 'TICKET';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                  child: Icon(typeIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['operator_name']?.toString() ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(booking['operator_number']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(typeLabel,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSportsOrEvent) ...[
                  // Sports/Event: Venue + City
                  _tiny(Icons.location_on, '${booking['from_location'] ?? ''}, ${booking['to_location'] ?? ''}'),
                  _tiny(Icons.calendar_today, booking['departure_date']?.toString() ?? ''),
                  _tiny(Icons.access_time, booking['departure_time']?.toString() ?? ''),
                ] else ...[
                  // Transport: Route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking['departure_time']?.toString() ?? '',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text(booking['from_location']?.toString() ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(booking['arrival_time']?.toString() ?? '',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text(booking['to_location']?.toString() ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _tiny(Icons.calendar_today, booking['departure_date']?.toString() ?? ''),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PKR ${double.tryParse(booking['total_amount']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('${passengers.length} Person(s)',
                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Person tickets
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.people, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('PERSON TICKETS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: AppColors.primary, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 12),

                if (passengers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                      child: Text('No person details',
                          style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
                  )
                else
                  Column(
                    children: List.generate(seats.length, (index) {
                      final seatId = seats[index];
                      final p = index < passengers.length ? passengers[index] : <String, dynamic>{};
                      final gender = p['gender']?.toString() ?? 'Male';
                      final isFemale = gender == 'Female';
                      final fullName = p['fullName']?.toString() ?? 'Unknown';

                      return Container(
                        margin: EdgeInsets.only(bottom: index == seats.length - 1 ? 0 : 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFemale
                                ? const Color(0xFFEC407A).withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.3))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: isFemale ? const Color(0xFFEC407A) : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text(seatId,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(isFemale ? Icons.female : Icons.male,
                                              size: 14, color: isFemale ? const Color(0xFFEC407A) : AppColors.primary),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(fullName,
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                      Text('CNIC: ${p['idNumber']?.toString() ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _detailRow(Icons.email_outlined, p['email']?.toString() ?? 'N/A'),
                            _detailRow(Icons.phone_outlined, p['phone']?.toString() ?? 'N/A'),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _saveTransportTicket(booking, seatId, p),
                                icon: const Icon(Icons.download, size: 14, color: Colors.white),
                                label: Text(
                                  'Download ${fullName.split(' ').first}\'s Ticket',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFemale ? const Color(0xFFEC407A) : AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(vertical: 10)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textDark))),
        ],
      ),
    );
  }

  Widget _tiny(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.textGrey))),
        ],
      ),
    );
  }
}