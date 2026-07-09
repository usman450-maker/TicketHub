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

  bool get _isSportsOrEvent =>
      widget.booking.transportType == 'sports' ||
      widget.booking.transportType == 'event';

  String get _typeLabel {
    switch (widget.booking.transportType) {
      case 'bus':
        return 'BUS';
      case 'flight':
        return 'FLIGHT';
      case 'train':
        return 'TRAIN';
      case 'sports':
        return 'SPORTS MATCH';
      case 'event':
        return 'EVENT';
      default:
        return 'TICKET';
    }
  }

  IconData get _typeIcon {
    switch (widget.booking.transportType) {
      case 'bus':
        return Icons.directions_bus;
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'sports':
        return Icons.stadium;
      case 'event':
        return Icons.celebration;
      default:
        return Icons.confirmation_number;
    }
  }

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
      if (widget.booking.passengers.isEmpty ||
          widget.booking.seatNumbers.isEmpty) {
        CustomSnackbar.showError(context, 'No person data');
        setState(() => _isSaving = false);
        return;
      }

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
            context, '$savedCount ticket(s) saved to Gallery!');
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

              // Success icon
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFC49B63),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                    color: Color(0xFFC49B63),
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Confirmation sent to your inbox.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Ticket Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(_typeIcon,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '$_typeLabel TICKET',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Confirmation Number
                    const Text(
                      'CONFIRMATION NUMBER',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    Text(
                      widget.orderNumber,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const Divider(height: 30),

                    // ==========================
                    // DIFFERENT LAYOUT PER TYPE
                    // ==========================
                    if (_isSportsOrEvent) ...[
                      // SPORTS / EVENT Layout
                      _infoField(
                        widget.booking.transportType == 'sports'
                            ? 'MATCH'
                            : 'EVENT',
                        widget.booking.operatorName,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoField(
                                'VENUE', widget.booking.fromLocation),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child:
                                _infoField('CITY', widget.booking.toLocation),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoField(
                        'CATEGORY',
                        widget.booking.classType ?? 'General',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _infoField(
                              widget.booking.transportType == 'sports'
                                  ? 'MATCH DATE'
                                  : 'EVENT DATE',
                              widget.booking.departureDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoField(
                              widget.booking.transportType == 'sports'
                                  ? 'MATCH TIME'
                                  : 'STARTS AT',
                              widget.booking.departureTime,
                            ),
                          ),
                        ],
                      ),
                      if (widget.booking.arrivalTime != null &&
                          widget.booking.arrivalTime!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _infoField(
                            'ENDS AT', widget.booking.arrivalTime!),
                      ],
                    ] else ...[
                      // BUS / TRAIN / FLIGHT Layout
                      _infoField('OPERATOR', widget.booking.operatorName),
                      const SizedBox(height: 12),
                      if (widget.booking.classType != null)
                        _infoField('CLASS', widget.booking.classType!),
                      const SizedBox(height: 16),

                      // Departure
                      const Text(
                        'DEPARTURE',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.booking.fromLocation,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.booking.departureDate} at ${widget.booking.departureTime}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),

                      // Arrow
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1, color: Colors.grey.shade300)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              widget.booking.transportType == 'flight'
                                  ? Icons.flight
                                  : widget.booking.transportType == 'train'
                                      ? Icons.train
                                      : Icons.directions_bus,
                              color: const Color(0xFFC49B63),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1, color: Colors.grey.shade300)),
                        ],
                      ),
                      Center(
                        child: Text(
                          'DIRECT${widget.booking.duration != null ? ' • ${widget.booking.duration}' : ''}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Arrival
                      const Text(
                        'ARRIVAL',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.booking.toLocation,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (widget.booking.arrivalTime != null)
                        Text(
                          widget.booking.arrivalTime!,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                    ],

                    const SizedBox(height: 16),

                    // Seats
                    if (widget.booking.seatNumbers.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _infoField(
                              'SEATS',
                              widget.booking.seatNumbers.join(', '),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoField(
                              'PERSONS',
                              '${widget.booking.passengers.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Total
                    _infoField(
                      'TOTAL PAID',
                      'PKR ${widget.booking.totalAmount.toStringAsFixed(0)}',
                    ),

                    const SizedBox(height: 20),

                    // QR Code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: widget.orderNumber,
                          version: QrVersions.auto,
                          size: 110,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _isSportsOrEvent
                            ? 'SCAN AT ENTRANCE'
                            : 'SCAN AT BOARDING',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
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
                              color: Colors.white, strokeWidth: 2))
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

              // Return
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

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}