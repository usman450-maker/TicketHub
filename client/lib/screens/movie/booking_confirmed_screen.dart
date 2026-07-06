import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/booking_data.dart';
import '../../services/storage_service.dart';
import '../../services/ticket_save_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'package:gal/gal.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final BookingData booking;
  final String orderNumber;

  const BookingConfirmedScreen({
    super.key,
    required this.booking,
    required this.orderNumber,
  });

  @override
  State<BookingConfirmedScreen> createState() =>
      _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  String _userName = 'Guest';
  String _userEmail = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    if (mounted && user != null) {
      setState(() {
        _userName = user['name'] ?? 'Guest';
        _userEmail = user['email'] ?? '';
      });
    }
  }

 Future<void> _saveTicket() async {
  setState(() => _isSaving = true);

  try {
    // First check permission
    final hasAccess = await Gal.hasAccess();
    
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        if (!mounted) return;
        _showPermissionDialog();
        setState(() => _isSaving = false);
        return;
      }
    }

    final success = await TicketSaveService.saveTicketToGallery(
      context: context,
      booking: widget.booking,
      orderNumber: widget.orderNumber,
      userName: _userName,
      userEmail: _userEmail,
    );

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context,
        '🎫 Ticket saved to Gallery!',
      );
    } else {
      CustomSnackbar.showError(
        context,
        'Failed to save. Check console for details.',
      );
    }
  } catch (e) {
    if (!mounted) return;
    CustomSnackbar.showError(context, 'Error: $e');
    print('Save error: $e');
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}

void _showPermissionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'TicketHub needs gallery access to save tickets.\n\n'
        'Please enable it in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await Gal.requestAccess();
          },
          child: const Text('Grant Permission'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'TicketHub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, RouteNames.home, (route) => false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Confirmation email sent to your inbox 📧',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),

              // Ticket Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF152A20),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (widget.booking.moviePoster.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.booking.moviePoster,
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 60,
                                    height: 80,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.booking.movieTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Screen ${widget.booking.screenNumber ?? 1}',
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
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _info('DATE', widget.booking.showDate)),
                                Expanded(child: _info('TIME', widget.booking.showTime, end: true)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _info('SEATS',
                                      widget.booking.selectedSeats.map((s) => s.id).join(", ")),
                                ),
                                Expanded(
                                  child: _info('CINEMA', widget.booking.venueName, end: true),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Paid',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.booking.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                data: widget.orderNumber,
                                version: QrVersions.auto,
                                size: 140,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ORDER #${widget.orderNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save to Gallery Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Saving...' : 'SAVE TICKET TO GALLERY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.home, (route) => false),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value, {bool end = false}) {
    return Column(
      crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGrey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: end ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}