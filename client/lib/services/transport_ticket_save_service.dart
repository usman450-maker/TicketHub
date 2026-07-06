import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../core/constants/app_colors.dart';
import '../models/transport_booking.dart';

class TransportTicketSaveService {
  static Future<bool> saveTicketToGallery({
    required BuildContext context,
    required TransportBooking booking,
    required String orderNumber,
    required Passenger passenger,
    required String seatId,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }

      final controller = ScreenshotController();

      final Uint8List? imageBytes = await controller.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 700),
            devicePixelRatio: 2.0,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.white,
              child: _TicketWidget(
                booking: booking,
                orderNumber: orderNumber,
                passenger: passenger,
                seatId: seatId,
              ),
            ),
          ),
        ),
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 500),
      );

      if (imageBytes == null) return false;

      await Gal.putImageBytes(
        imageBytes,
        album: 'TicketHub',
        name: 'TicketHub_${orderNumber}_$seatId',
      );

      return true;
    } catch (e) {
      print('Save error: $e');
      return false;
    }
  }
}

class _TicketWidget extends StatelessWidget {
  final TransportBooking booking;
  final String orderNumber;
  final Passenger passenger;
  final String seatId;

  const _TicketWidget({
    required this.booking,
    required this.orderNumber,
    required this.passenger,
    required this.seatId,
  });

  bool get _isSports => booking.transportType == 'sports';

String get _typeLabel {
  switch (booking.transportType) {
    case 'bus': return 'BUS TICKET';
    case 'flight': return 'FLIGHT TICKET';
    case 'train': return 'TRAIN TICKET';
    case 'sports': return 'SPORTS TICKET';
    case 'event': return 'EVENT TICKET';
    default: return 'E-TICKET';
  }
}

IconData get _typeIcon {
  switch (booking.transportType) {
    case 'bus': return Icons.directions_bus;
    case 'flight': return Icons.flight;
    case 'train': return Icons.train;
    case 'sports': return Icons.stadium;
    case 'event': return Icons.celebration;
    default: return Icons.confirmation_number;
  }
}

bool get _isSportsTicket => 
    booking.transportType == 'sports' || booking.transportType == 'event';

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pricePerSeat = booking.totalAmount /
        (booking.passengers.isEmpty ? 1 : booking.passengers.length);

    return Container(
      width: 400,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==========================
          // HEADER (Green)
          // ==========================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_typeIcon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'TICKETHUB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _typeLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================
          // BODY
          // ==========================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Confirmed badge
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
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Operator / Match name
                Text(
                  booking.operatorName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),

                // ==========================
                // INFO GRID (2 columns)
                // ==========================
                if (_isSports) ...[
                  // Sports layout
                  Row(
                    children: [
                      Expanded(child: _mini('VENUE', booking.fromLocation)),
                      const SizedBox(width: 6),
                      Expanded(child: _mini('CITY', booking.toLocation)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _mini('MATCH DATE', booking.departureDate)),
                      const SizedBox(width: 6),
                      Expanded(child: _mini('MATCH TIME', booking.departureTime)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _mini('CATEGORY', booking.classType ?? 'General'),
                ] else ...[
                  // Bus/Train/Flight layout
                  _mini('ROUTE', '${booking.fromLocation} → ${booking.toLocation}'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _mini('DATE', booking.departureDate)),
                      const SizedBox(width: 6),
                      Expanded(child: _mini('DEPARTURE', booking.departureTime)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _mini('ARRIVAL', booking.arrivalTime ?? 'N/A')),
                      const SizedBox(width: 6),
                      Expanded(child: _mini('CLASS', booking.classType ?? 'Standard')),
                    ],
                  ),
                ],
                const SizedBox(height: 10),

                // ==========================
                // PERSON DETAILS
                // ==========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text(
                            'PERSON DETAILS',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          // SEAT badge inline
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SEAT: $seatId',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _row('Name', passenger.fullName),
                      _row('CNIC', passenger.idNumber),
                      _row('Gender', passenger.gender),
                      _row('Email', passenger.email),
                      _row('Phone', passenger.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Fare + Issue info
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _row('Order #', orderNumber),
                      _row('Issue Date', _getCurrentDate()),
                      _row('Issue Time', _getCurrentTime()),
                      const Divider(height: 10),
                      _row('Fare Paid', 'PKR ${pricePerSeat.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ==========================
                // DASHED LINE
                // ==========================
                Row(
                  children: List.generate(
                    50,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 1,
                        color: index.isEven
                            ? Colors.grey.shade400
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ==========================
                // QR CODE (CENTER BOTTOM)
                // ==========================
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: QrImageView(
                          data: '$orderNumber-$seatId',
                          version: QrVersions.auto,
                          size: 100,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ORDER #$orderNumber',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SCAN AT ENTRANCE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================
          // FOOTER
          // ==========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: const Color(0xFF152A20),
            child: const Text(
              'EXCELLENCE IN EVERY ARRIVAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textGrey),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isBold ? 12 : 10,
                fontWeight: FontWeight.bold,
                color: isBold ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}