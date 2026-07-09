import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_data.dart';
import '../../../models/transport_booking.dart';
import '../../../services/booking_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/ticket_save_service.dart';
import '../../../services/transport_service.dart';
import '../../../services/transport_ticket_save_service.dart';
import '../../../services/park_service.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../services/refund_service.dart';
import '../../notifications/notifications_screen.dart';
import 'dart:io';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = true;
  String _userName = 'Guest';
  String _userEmail = '';
  bool _showUpcoming = true;
  String? _profileImagePath; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await StorageService.getUser();
    if (user != null) {
      _userName = user['name'] ?? 'Guest';
      _userEmail = user['email'] ?? '';
    }
      // ✅ Ye add karo
  _profileImagePath = await StorageService.getProfileImage();

 

    List<Map<String, dynamic>> all = [];

    // Movie bookings
    try {
      final res = await BookingService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          all.add({
            ...Map<String, dynamic>.from(b),
            '_type': 'movie',
            '_title': b['movie_title']?.toString() ?? '',
            '_subtitle': '${b['venue_name'] ?? ''} • Screen ${b['screen_number'] ?? 1}',
            '_date': b['show_date']?.toString() ?? '',
            '_time': b['show_time']?.toString() ?? '',
            '_image': b['movie_poster']?.toString() ?? '',
            '_icon': 'movie',
            '_tag': 'MOVIE',
          });
        }
      }
    } catch (e) {}

    // Transport bookings (bus, train, flight, sports, event)
    try {
      final res = await TransportService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          final type = b['transport_type']?.toString().toLowerCase() ?? '';
          String tag = type.toUpperCase();
          String icon = type;
          String subtitle = '';

          if (type == 'sports' || type == 'event') {
            subtitle = '${b['from_location'] ?? ''}, ${b['to_location'] ?? ''}';
          } else {
            subtitle = '${b['from_location'] ?? ''} → ${b['to_location'] ?? ''}';
          }

          all.add({
            ...Map<String, dynamic>.from(b),
            '_type': type,
            '_title': b['operator_name']?.toString() ?? '',
            '_subtitle': subtitle,
            '_date': b['departure_date']?.toString() ?? '',
            '_time': b['departure_time']?.toString() ?? '',
            '_image': '',
            '_icon': icon,
            '_tag': tag,
          });
        }
      }
    } catch (e) {}

    // Park bookings
    try {
      final res = await ParkService.getMyBookings();
      if (res['success'] == true && res['bookings'] != null) {
        for (var b in res['bookings']) {
          all.add({
            ...Map<String, dynamic>.from(b),
            '_type': 'park',
            '_title': b['park_name']?.toString() ?? '',
            '_subtitle': b['park_city']?.toString() ?? '',
            '_date': b['visit_date']?.toString() ?? '',
            '_time': '',
            '_image': b['park_image']?.toString() ?? '',
            '_icon': 'park',
            '_tag': 'PARK PASS',
          });
        }
      }
    } catch (e) {}

    // Sort by date (newest first)
    all.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    if (mounted) {
      setState(() {
        _allBookings = all;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
            // ✅ Header - Avatar Left + Notification Right
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
      // ✅ Notification Icon (right)
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

              // Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Text('My Bookings',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Manage your journeys and event experiences.',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textGrey)),
              ),
              const SizedBox(height: 20),

              // Upcoming / Past toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showUpcoming = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _showUpcoming
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text('Upcoming',
                                  style: TextStyle(
                                      color: _showUpcoming
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showUpcoming = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_showUpcoming
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text('Past',
                                  style: TextStyle(
                                      color: !_showUpcoming
                                          ? Colors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary)),
                )
              else if (_allBookings.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            size: 80,
                            color: AppColors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('No bookings yet',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                )
              else ...[
                // Featured (first booking)
                if (_allBookings.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('NEXT EXPERIENCE',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGrey,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 12),
                  _buildFeaturedCard(_allBookings[0]),
                  const SizedBox(height: 24),
                ],

                // Rest of bookings
                if (_allBookings.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _allBookings
                          .skip(1)
                          .map((b) => _buildCompactCard(b))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // FEATURED CARD (Big, first booking)
  // ==========================
  Widget _buildFeaturedCard(Map<String, dynamic> booking) {
    final title = booking['_title']?.toString() ?? '';
    final tag = booking['_tag']?.toString() ?? '';
    final date = booking['_date']?.toString() ?? '';
    final time = booking['_time']?.toString() ?? '';
    final image = booking['_image']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _openTicketDetail(booking),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background
                Positioned.fill(
                  child: image.isNotEmpty
                      ? Image.network(image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                              color: AppColors.primary))
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                Color(0xFF1A3D28),
                              ],
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
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC49B63),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                      const SizedBox(height: 10),
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(date,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          if (time.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(time,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('View Ticket',
                                style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward,
                                color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================
  // COMPACT CARD (Smaller, rest of bookings)
  // ==========================
  Widget _buildCompactCard(Map<String, dynamic> booking) {
    final title = booking['_title']?.toString() ?? '';
    final subtitle = booking['_subtitle']?.toString() ?? '';
    final date = booking['_date']?.toString() ?? '';
    final time = booking['_time']?.toString() ?? '';
    final image = booking['_image']?.toString() ?? '';
    final type = booking['_type']?.toString() ?? '';

    IconData icon;
    switch (type) {
      case 'movie':
        icon = Icons.movie;
        break;
      case 'bus':
        icon = Icons.directions_bus;
        break;
      case 'flight':
        icon = Icons.flight;
        break;
      case 'train':
        icon = Icons.train;
        break;
      case 'sports':
        icon = Icons.stadium;
        break;
      case 'event':
        icon = Icons.celebration;
        break;
      case 'park':
        icon = Icons.park;
        break;
      default:
        icon = Icons.confirmation_number;
    }

    return GestureDetector(
      onTap: () => _openTicketDetail(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            // Image or Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image.isNotEmpty
                  ? Image.network(image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(icon,
                              color: AppColors.primary, size: 30)))
                  : Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(icon, color: AppColors.primary, size: 30),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGrey)),
                  const SizedBox(height: 4),
                  Text('$date${time.isNotEmpty ? ' • $time' : ''}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),

            // View Ticket
            const Text('View\nTicket',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ==========================
  // OPEN TICKET DETAIL
  // ==========================
  void _openTicketDetail(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TicketDetailScreen(
          booking: booking,
          userName: _userName,
          userEmail: _userEmail,
        ),
      ),
    );
  }
}

// ==========================
// TICKET DETAIL SCREEN
// ==========================
class _TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String userName;
  final String userEmail;

  const _TicketDetailScreen({
    required this.booking,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<_TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<_TicketDetailScreen> {
  bool _isSaving = false;

  String get _type => widget.booking['_type']?.toString() ?? '';
  String get _title => widget.booking['_title']?.toString() ?? '';
  String get _tag => widget.booking['_tag']?.toString() ?? '';
  String get _date => widget.booking['_date']?.toString() ?? '';
  String get _time => widget.booking['_time']?.toString() ?? '';
  String get _image => widget.booking['_image']?.toString() ?? '';
  String get _subtitle => widget.booking['_subtitle']?.toString() ?? '';
  String get _orderNumber =>
      widget.booking['order_number']?.toString() ?? '';

  bool get _isSportsOrEvent =>
      _type == 'sports' || _type == 'event';
  bool get _isPark => _type == 'park';
  bool get _isTransport =>
      _type == 'bus' || _type == 'train' || _type == 'flight';

  double get _total =>
      double.tryParse(
          widget.booking['total_amount']?.toString() ?? '0') ??
      0;

  IconData get _icon {
    switch (_type) {
      case 'movie': return Icons.movie;
      case 'bus': return Icons.directions_bus;
      case 'flight': return Icons.flight;
      case 'train': return Icons.train;
      case 'sports': return Icons.stadium;
      case 'event': return Icons.celebration;
      case 'park': return Icons.park;
      default: return Icons.confirmation_number;
    }
  }

Future<void> _saveTicket() async {
  setState(() => _isSaving = true);

  try {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        setState(() => _isSaving = false);
        return;
      }
    }

    bool success = false;

    if (_type == 'movie') {
      // Use movie ticket format
      success = await _saveMovieTicket();
    } else if (_type == 'bus' || _type == 'train' || _type == 'flight' ||
        _type == 'sports' || _type == 'event') {
      // Use transport ticket format (same as before)
      success = await _saveTransportTicket();
    } else if (_type == 'park') {
      // Use park ticket format
      success = await _saveParkTicket();
    } else {
      // Generic fallback
      success = await _saveGenericTicket();
    }

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(context, 'Ticket saved to Gallery!');
    } else {
      CustomSnackbar.showError(context, 'Failed to save ticket');
    }
  } catch (e) {
    if (!mounted) return;
    CustomSnackbar.showError(context, 'Error: $e');
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}


// ✅ Request Refund
Future<void> _requestRefund() async {
  final reasonController = TextEditingController();

  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(Icons.replay_circle_filled,
              color: AppColors.primary, size: 24),
          SizedBox(width: 8),
          Text('Request Refund'),
        ],
      ),
      // ✅ Wrap in SingleChildScrollView + ConstrainedBox
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Refund Policy:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• 48+ hours before: 100% refund\n'
                '• 24-48 hours: 75% refund\n'
                '• 12-24 hours: 50% refund\n'
                '• 6-12 hours: 25% refund\n'
                '• Less than 6 hours: No refund',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for refund',
                  hintText: 'Why do you want to cancel?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (reasonController.text.trim().isEmpty) {
              CustomSnackbar.showError(
                  context, 'Please provide a reason');
              return;
            }
            Navigator.pop(context, reasonController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Submit',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (reason == null || reason.isEmpty) return;

  // ... rest of the code (loading + API call)
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    ),
  );

  try {
    final response = await RefundService.requestRefund(
      bookingId: widget.booking['id'] ?? 0,
      bookingType: _type,
      orderNumber: _orderNumber,
      originalAmount: _total,
      reason: reason,
      paymentId: widget.booking['payment_id']?.toString() ?? '',
      bookingDate: _date,
      bookingTime: _time.isEmpty ? '00:00' : _time,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (response['success'] == true) {
      CustomSnackbar.showSuccess(
        context,
        'Refund request submitted! You will be notified once processed.',
      );
      Navigator.pop(context);
    } else {
      CustomSnackbar.showError(
        context,
        response['message'] ?? 'Failed to request refund',
      );
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    CustomSnackbar.showError(context, 'Error: $e');
  }
}

// MOVIE TICKET
Future<bool> _saveMovieTicket() async {
  List<dynamic> rawSeats = [];
  if (widget.booking['seats'] != null) {
    if (widget.booking['seats'] is List) {
      rawSeats = widget.booking['seats'];
    } else if (widget.booking['seats'] is String) {
      rawSeats = widget.booking['seats'].toString()
          .replaceAll('{', '').replaceAll('}', '')
          .split(',').map((s) => s.trim()).toList();
    }
  }

  final seats = rawSeats.map((s) {
    final id = s.toString();
    String tier = 'STANDARD';
    double price = 15;
    if (id.isNotEmpty) {
      if (['C','D','E'].contains(id[0])) { tier = 'PREMIUM'; price = 25; }
      else if (['F','G'].contains(id[0])) { tier = 'GOLD CLASS'; price = 45; }
    }
    return SeatSelection(id: id, tier: tier, price: price);
  }).toList();

  final bookingData = BookingData(
    movieId: widget.booking['movie_id'] ?? 0,
    movieTitle: widget.booking['movie_title']?.toString() ?? '',
    moviePoster: widget.booking['movie_poster']?.toString() ?? '',
    movieBackdrop: '',
    venueName: widget.booking['venue_name']?.toString() ?? '',
    venueLocation: widget.booking['venue_location']?.toString() ?? '',
    showDate: widget.booking['show_date']?.toString() ?? '',
    showTime: widget.booking['show_time']?.toString() ?? '',
    screenNumber: widget.booking['screen_number'] ?? 1,
    selectedSeats: seats,
  );

  return await TicketSaveService.saveTicketToGallery(
    context: context,
    booking: bookingData,
    orderNumber: _orderNumber,
    userName: widget.userName,
    userEmail: widget.userEmail,
  );
}

// TRANSPORT/SPORTS/EVENT TICKET
Future<bool> _saveTransportTicket() async {
  final passengers = _parsePassengers(widget.booking['passenger_details']);
  final seatList = _parseSeats(widget.booking['seat_numbers']);

  if (passengers.isEmpty || seatList.isEmpty) {
    // Save generic if no passenger data
    return await _saveGenericTicket();
  }

  // Save first passenger ticket
  final p = passengers[0];
  final passenger = Passenger(
    fullName: p['fullName']?.toString() ?? widget.userName,
    idNumber: p['idNumber']?.toString() ?? '',
    gender: p['gender']?.toString() ?? 'Male',
    age: p['age'] is int ? p['age'] : int.tryParse(p['age']?.toString() ?? '0') ?? 0,
    nationality: p['nationality']?.toString() ?? '',
    email: p['email']?.toString() ?? widget.userEmail,
    phone: p['phone']?.toString() ?? '',
  );

  final allPassengers = passengers.map((pp) => Passenger(
    fullName: pp['fullName']?.toString() ?? '',
    idNumber: pp['idNumber']?.toString() ?? '',
    gender: pp['gender']?.toString() ?? 'Male',
    age: pp['age'] is int ? pp['age'] : int.tryParse(pp['age']?.toString() ?? '0') ?? 0,
    nationality: pp['nationality']?.toString() ?? '',
    email: pp['email']?.toString() ?? '',
    phone: pp['phone']?.toString() ?? '',
  )).toList();

  final total = double.tryParse(widget.booking['total_amount']?.toString() ?? '0') ?? 0;

  final transportBooking = TransportBooking(
    transportType: _type,
    operatorName: widget.booking['operator_name']?.toString() ?? _title,
    operatorNumber: widget.booking['operator_number']?.toString() ?? '',
    fromLocation: widget.booking['from_location']?.toString() ?? '',
    toLocation: widget.booking['to_location']?.toString() ?? '',
    departureDate: widget.booking['departure_date']?.toString() ?? _date,
    departureTime: widget.booking['departure_time']?.toString() ?? _time,
    arrivalTime: widget.booking['arrival_time']?.toString(),
    duration: widget.booking['duration']?.toString(),
    classType: widget.booking['class_type']?.toString(),
    seatNumbers: seatList,
    passengers: allPassengers,
    pricePerPassenger: total / (allPassengers.isEmpty ? 1 : allPassengers.length),
  );

  return await TransportTicketSaveService.saveTicketToGallery(
    context: context,
    booking: transportBooking,
    orderNumber: _orderNumber,
    passenger: passenger,
    seatId: seatList.isNotEmpty ? seatList[0] : '',
  );
}

// PARK TICKET
Future<bool> _saveParkTicket() async {
  Map<String, dynamic> personDetails = {};
  try {
    if (widget.booking['person_details'] is Map) {
      personDetails = Map<String, dynamic>.from(widget.booking['person_details']);
    }
  } catch (e) {}

  final controller = ScreenshotController();

  final imageBytes = await controller.captureFromWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(360, 550), devicePixelRatio: 2.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: _ParkTicketWidget(
            parkName: widget.booking['park_name']?.toString() ?? _title,
            parkCity: widget.booking['park_city']?.toString() ?? '',
            orderNumber: _orderNumber,
            visitDate: widget.booking['visit_date']?.toString() ?? _date,
            adultQty: widget.booking['adult_qty'] ?? 0,
            childQty: widget.booking['child_qty'] ?? 0,
            seniorQty: widget.booking['senior_qty'] ?? 0,
            total: _total,
            personName: personDetails['name']?.toString() ?? widget.userName,
            personEmail: personDetails['email']?.toString() ?? widget.userEmail,
            personPhone: personDetails['phone']?.toString() ?? '',
            personCnic: personDetails['cnic']?.toString() ?? '',
          ),
        ),
      ),
    ),
    pixelRatio: 2.5,
    delay: const Duration(milliseconds: 500),
  );

  await Gal.putImageBytes(
    imageBytes,
    album: 'TicketHub',
    name: 'TicketHub_$_orderNumber',
  );

  return true;
}

// GENERIC TICKET (fallback)
Future<bool> _saveGenericTicket() async {
  final controller = ScreenshotController();

  final imageBytes = await controller.captureFromWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(360, 550), devicePixelRatio: 2.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: _UniversalTicketWidget(
            booking: widget.booking,
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
        ),
      ),
    ),
    pixelRatio: 2.5,
    delay: const Duration(milliseconds: 500),
  );

  await Gal.putImageBytes(
    imageBytes,
    album: 'TicketHub',
    name: 'TicketHub_$_orderNumber',
  );

  return true;
}

List<String> _parseSeats(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) return List<String>.from(raw.map((s) => s.toString()));
  if (raw is String) {
    return raw.replaceAll('{', '').replaceAll('}', '')
        .split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  return [];
}

List<Map<String, dynamic>> _parsePassengers(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.map((p) {
      if (p is Map) return Map<String, dynamic>.from(p);
      return <String, dynamic>{};
    }).toList();
  }
  return [];
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
              padding: const EdgeInsets.all(16),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // CONFIRMED BOOKING
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('CONFIRMED BOOKING',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGrey,
                              letterSpacing: 2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      child: Text(_title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    // Image/Banner
                    if (_image.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16),
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(_image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        Container(
                                            color: AppColors
                                                .primaryLight)),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black
                                            .withValues(alpha: 0.6),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                bottom: 14,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('VENUE',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.bold)),
                                    Text(_subtitle,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 14,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(_tag,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16),
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(_icon,
                                  color: Colors.white, size: 40),
                              const SizedBox(height: 6),
                              Text(_tag,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Details Card
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _info('DATE', _date)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _info('TIME',
                                        _time.isEmpty
                                            ? 'N/A'
                                            : _time)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (_isTransport) ...[
                              _info('FROM',
                                  widget.booking['from_location']?.toString() ?? ''),
                              const SizedBox(height: 12),
                              _info('TO',
                                  widget.booking['to_location']?.toString() ?? ''),
                            ] else if (_isPark) ...[
                              _info('PARK',
                                  widget.booking['park_name']?.toString() ?? ''),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if ((widget.booking['adult_qty'] ?? 0) > 0)
                                    Expanded(child: _info('ADULTS',
                                        '${widget.booking['adult_qty']}')),
                                  if ((widget.booking['child_qty'] ?? 0) > 0)
                                    Expanded(child: _info('CHILDREN',
                                        '${widget.booking['child_qty']}')),
                                  if ((widget.booking['senior_qty'] ?? 0) > 0)
                                    Expanded(child: _info('SENIORS',
                                        '${widget.booking['senior_qty']}')),
                                ],
                              ),
                            ] else if (_isSportsOrEvent) ...[
                              _info('VENUE',
                                  widget.booking['from_location']?.toString() ?? ''),
                              const SizedBox(height: 12),
                              _info('CITY',
                                  widget.booking['to_location']?.toString() ?? ''),
                            ] else ...[
                              // Movie
                              _info('VENUE',
                                  widget.booking['venue_name']?.toString() ?? ''),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _info('SCREEN',
                                      'Screen ${widget.booking['screen_number'] ?? 1}')),
                                  Expanded(child: _info('SEATS',
                                      _parseSeats(widget.booking['seats']).join(', '))),
                                ],
                              ),
                            ],

                            // Dashed line
                            const SizedBox(height: 20),
                            Row(
                              children: List.generate(
                                30,
                                (i) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets
                                        .symmetric(horizontal: 1),
                                    height: 1,
                                    color: i.isEven
                                        ? AppColors.borderGrey
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // QR Code
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                data: _orderNumber,
                                version: QrVersions.auto,
                                size: 140,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('SCAN AT ENTRANCE',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 1.5)),
                            const SizedBox(height: 6),
                            Text('Order #$_orderNumber',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey)),
                            const SizedBox(height: 6),
                            Text(
                                'Total: PKR ${_total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveTicket,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                              : const Icon(Icons.download,
                                  color: Colors.white),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : 'Save Ticket to Gallery',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Request Refund Button
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton.icon(
      onPressed: _requestRefund,
      icon: const Icon(Icons.replay_circle_filled,
          color: AppColors.primary),
      label: const Text(
        'Request Refund',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  ),
),
const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textGrey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }


}

// ==========================
// UNIVERSAL TICKET WIDGET (for gallery save)
// ==========================
class _UniversalTicketWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String userName;
  final String userEmail;

  const _UniversalTicketWidget({
    required this.booking,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final issueDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final issueTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final type = booking['_type']?.toString() ?? '';
    final title = booking['_title']?.toString() ?? '';
    final tag = booking['_tag']?.toString() ?? '';
    final date = booking['_date']?.toString() ?? '';
    final time = booking['_time']?.toString() ?? '';
    final orderNumber = booking['order_number']?.toString() ?? '';
    final total =
        double.tryParse(booking['total_amount']?.toString() ?? '0') ?? 0;

    IconData icon;
    switch (type) {
      case 'movie': icon = Icons.movie; break;
      case 'bus': icon = Icons.directions_bus; break;
      case 'flight': icon = Icons.flight; break;
      case 'train': icon = Icons.train; break;
      case 'sports': icon = Icons.stadium; break;
      case 'event': icon = Icons.celebration; break;
      case 'park': icon = Icons.park; break;
      default: icon = Icons.confirmation_number;
    }

    return Container(
      width: 360,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header + QR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Icon(icon,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('TICKETHUB',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(2),
                          ),
                          child: Text(tag,
                              style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black, width: 0.5)),
                  child: QrImageView(
                      data: orderNumber,
                      version: QrVersions.auto,
                      size: 80),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Issue info
            Row(
              children: [
                Expanded(child: _f('Serial No.', orderNumber)),
                const SizedBox(width: 4),
                Expanded(child: _f('Issue Date', issueDate)),
                const SizedBox(width: 4),
                Expanded(child: _f('Issue Time', issueTime)),
              ],
            ),
            const SizedBox(height: 6),

            _f('Name / Title', title, isFull: true),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(child: _f('Date', date)),
                const SizedBox(width: 4),
                Expanded(
                    child: _f('Time', time.isEmpty ? 'N/A' : time)),
              ],
            ),
            const SizedBox(height: 6),

            _f('Booked By', userName, isFull: true),
            const SizedBox(height: 6),
            _f('Email', userEmail, isFull: true),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                    child: _f(
                        'Total (PKR)', total.toStringAsFixed(0))),
                const SizedBox(width: 4),
                Expanded(child: _f('Status', 'PAID')),
              ],
            ),
            const SizedBox(height: 8),

            // Footer
            const Divider(color: Colors.black26, height: 6),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Powered by TicketHub',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('CONFIRMED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(String label, String value, {bool isFull = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(
                color: Colors.grey.shade400, width: 0.5),
          ),
          width: double.infinity,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey.shade400, width: 0.5),
          ),
          width: double.infinity,
          child: Text(value,
              style: TextStyle(
                  fontSize: isFull ? 10 : 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  } 
}
class _ParkTicketWidget extends StatelessWidget {
  final String parkName, parkCity, orderNumber, visitDate;
  final int adultQty, childQty, seniorQty;
  final double total;
  final String personName, personEmail, personPhone, personCnic;

  const _ParkTicketWidget({
    required this.parkName, required this.parkCity,
    required this.orderNumber, required this.visitDate,
    required this.adultQty, required this.childQty, required this.seniorQty,
    required this.total,
    required this.personName, required this.personEmail,
    required this.personPhone, required this.personCnic,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final issueDate = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';
    final issueTime = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';

    return Container(
      width: 360, color: Colors.white, padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)),
                    child: const Icon(Icons.park, color: Colors.white, size: 14)),
                  const SizedBox(width: 5),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('TICKETHUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                      child: const Text('PARK PASS', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  ]),
                ]),
                Container(padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                  child: QrImageView(data: orderNumber, version: QrVersions.auto, size: 80)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _f('Serial No.', orderNumber)),
              const SizedBox(width: 4),
              Expanded(child: _f('Issue Date', issueDate)),
              const SizedBox(width: 4),
              Expanded(child: _f('Issue Time', issueTime)),
            ]),
            const SizedBox(height: 6),
            _f('Park', parkName, isFull: true),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _f('City', parkCity)),
              const SizedBox(width: 4),
              Expanded(child: _f('Visit Date', visitDate)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              if (adultQty > 0) Expanded(child: _f('Adults', '$adultQty')),
              if (childQty > 0) ...[const SizedBox(width: 4), Expanded(child: _f('Children', '$childQty'))],
              if (seniorQty > 0) ...[const SizedBox(width: 4), Expanded(child: _f('Seniors', '$seniorQty'))],
            ]),
            const SizedBox(height: 6),
            _f('Person', personName, isFull: true),
            const SizedBox(height: 6),
            _f('Email', personEmail, isFull: true),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _f('Phone', personPhone)),
              if (personCnic.isNotEmpty) ...[const SizedBox(width: 4), Expanded(child: _f('CNIC', personCnic))],
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _f('Total (PKR)', total.toStringAsFixed(0))),
              const SizedBox(width: 4),
              Expanded(child: _f('Status', 'PAID')),
            ]),
            const SizedBox(height: 8),
            const Divider(color: Colors.black26, height: 6),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Powered by TicketHub', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(3)),
                child: const Text('CONFIRMED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _f(String label, String value, {bool isFull = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(color: Colors.grey.shade200, border: Border.all(color: Colors.grey.shade400, width: 0.5)),
        width: double.infinity,
        child: Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black87))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 0.5)),
        width: double.infinity,
        child: Text(value, style: TextStyle(fontSize: isFull ? 10 : 9, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}