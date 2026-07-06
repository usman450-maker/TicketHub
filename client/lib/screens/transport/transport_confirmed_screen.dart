import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/transport_booking.dart';
import '../../services/storage_service.dart';
import '../../services/transport_ticket_save_service.dart';
import '../../widgets/custom_snackbar.dart';

class TransportConfirmedScreen extends StatefulWidget {
  final TransportBooking booking;
  final String orderNumber;

  const TransportConfirmedScreen({
    super.key,
    required this.booking,
    required this.orderNumber,
  });

  @override
  State<TransportConfirmedScreen> createState() =>
      _TransportConfirmedScreenState();
}

class _TransportConfirmedScreenState extends State<TransportConfirmedScreen> {
  bool _isSaving = false;
  String _userName = 'Guest';
  String _userEmail = '';

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
    // Save ticket for FIRST passenger with FIRST seat
    if (widget.booking.passengers.isEmpty || widget.booking.seatNumbers.isEmpty) {
      CustomSnackbar.showError(context, 'No passenger data');
      setState(() => _isSaving = false);
      return;
    }

    // Save for each passenger
    int savedCount = 0;
    for (var i = 0; i < widget.booking.passengers.length; i++) {
      final passenger = widget.booking.passengers[i];
      final seatId = i < widget.booking.seatNumbers.length 
          ? widget.booking.seatNumbers[i] 
          : '';

      final success = await TransportTicketSaveService.saveTicketToGallery(
        context: context,
        booking: widget.booking,
        orderNumber: widget.orderNumber,
        passenger: passenger,
        seatId: seatId,
      );

      if (success) savedCount++;
    }

    if (!mounted) return;

    if (savedCount > 0) {
      CustomSnackbar.showSuccess(
        context, 
        '$savedCount ticket(s) saved to Gallery!',
      );
    } else {
      CustomSnackbar.showError(context, 'Failed to save tickets');
    }
  } catch (e) {
    if (!mounted) return;
    CustomSnackbar.showError(context, 'Error: $e');
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F16),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.check_circle,
                  color: Color(0xFFC49B63), size: 60),
              const SizedBox(height: 12),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                    color: Color(0xFFC49B63),
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Your journey is all set. Confirmation sent to your inbox.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONFIRMATION NUMBER',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.orderNumber,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 30),
                    _info('OPERATOR', widget.booking.operatorName),
                    _info('CLASS', widget.booking.classType ?? ''),
                    const SizedBox(height: 10),
                    _info('DEPARTURE', widget.booking.fromLocation),
                    Text(
                      '${widget.booking.departureDate} at ${widget.booking.departureTime}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_downward,
                              color: Color(0xFFC49B63)),
                        ),
                        Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _info('ARRIVAL', widget.booking.toLocation),
                    if (widget.booking.arrivalTime != null)
                      Text(
                        widget.booking.arrivalTime!,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 12),
                    _info('PASSENGERS',
                        '${widget.booking.passengers.length} person(s)'),
                    _info('TOTAL PAID', 'PKR ${widget.booking.totalAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: widget.orderNumber,
                          version: QrVersions.auto,
                          size: 110,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTicket,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.download, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Download E-Ticket',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF152A20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.home, (route) => false),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(
                      color: Color(0xFFC49B63), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}