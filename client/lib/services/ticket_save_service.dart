import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import '../models/booking_data.dart';
import '../widgets/ticket_image_widget.dart';

class TicketSaveService {
  static Future<bool> saveTicketToGallery({
    required BuildContext context,
    required BookingData booking,
    required String orderNumber,
    required String userName,
    required String userEmail,
  }) async {
    try {
      print('🎫 Starting ticket save...');

      // Check permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }

      final controller = ScreenshotController();

      print('📸 Capturing widget...');

      final Uint8List? imageBytes = await controller.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 900),  // ← Height increased
            devicePixelRatio: 2.0,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.white,
              child: TicketImageWidget(
                booking: booking,
                orderNumber: orderNumber,
                userName: userName,
                userEmail: userEmail,
              ),
            ),
          ),
        ),
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 500),
      );

      if (imageBytes == null) {
        print('❌ Image bytes null');
        return false;
      }

      print('✅ Image captured: ${imageBytes.length} bytes');

      await Gal.putImageBytes(
        imageBytes,
        album: 'TicketHub',
        name: 'TicketHub_$orderNumber',
      );

      print('✅ Saved successfully!');
      return true;
    } catch (e, stack) {
      print('❌ Error: $e');
      print('Stack: $stack');
      return false;
    }
  }
}