import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class BookingService {
  // Get already booked seats
  static Future<List<String>> getBookedSeats({
  required int movieId,
  required String venueName,
  required String showDate,
  required String showTime,
  required int screenNumber,
}) async {
  final token = await StorageService.getToken();

  final response = await ApiService.post(
    url: ApiEndpoints.bookedSeats,
    token: token,
    body: {
      'movieId': movieId,
      'venueName': venueName,
      'showDate': showDate,
      'showTime': showTime,
      'screenNumber': screenNumber,
    },
  );

  if (response['success'] == true && response['bookedSeats'] != null) {
    return List<String>.from(response['bookedSeats']);
  }
  return [];
}

  // Create Stripe payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
  }) async {
    final token = await StorageService.getToken();

    return await ApiService.post(
      url: ApiEndpoints.createPaymentIntent,
      token: token,
      body: {'amount': amount, 'currency': 'usd'},
    );
  }

  // Confirm booking after payment
  static Future<Map<String, dynamic>> confirmBooking({
  required Map<String, dynamic> bookingData,
  required String paymentId,
}) async {
  final token = await StorageService.getToken();

  return await ApiService.post(
    url: ApiEndpoints.confirmBooking,
    token: token,
    body: {
      ...bookingData,  // ← This will include screenNumber and showId
      'paymentId': paymentId,
    },
  );
}
  // Get user's bookings
static Future<Map<String, dynamic>> getMyBookings() async {
  final token = await StorageService.getToken();
  print('🎬 Fetching movie bookings...');
  print('🎬 Token exists: ${token != null && token.isNotEmpty}');
  print('🎬 URL: ${ApiEndpoints.myBookings}');
  
  final response = await ApiService.get(
    url: ApiEndpoints.myBookings,
    token: token,
  );
  
  print('🎬 Response: $response');
  return response;
}
}