import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class TransportService {
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
  }) async {
    final token = await StorageService.getToken();
    return await ApiService.post(
      url: ApiEndpoints.transportPaymentIntent,
      token: token,
      body: {'amount': amount, 'currency': 'usd'},
    );
  }
static Future<Map<String, dynamic>> getBookedSeats({
  required String operatorNumber,
  required String departureDate,
  required String departureTime,
}) async {
  final token = await StorageService.getToken();
  final response = await ApiService.post(
    url: ApiEndpoints.transportBookedSeats,
    token: token,
    body: {
      'operatorNumber': operatorNumber,
      'departureDate': departureDate,
      'departureTime': departureTime,
    },
  );

  if (response['success'] == true) {
    return {
      'seatMap': Map<String, String>.from(response['seatMap'] ?? {}),
      'bookedCNICs': List<String>.from(response['bookedCNICs'] ?? []),
    };
  }
  return {'seatMap': <String, String>{}, 'bookedCNICs': <String>[]};
}

  static Future<Map<String, dynamic>> confirmBooking({
    required Map<String, dynamic> bookingData,
    required String paymentId,
  }) async {
    final token = await StorageService.getToken();
    return await ApiService.post(
      url: ApiEndpoints.confirmTransportBooking,
      token: token,
      body: {...bookingData, 'paymentId': paymentId},
    );
  }

  static Future<Map<String, dynamic>> getMyBookings() async {
    final token = await StorageService.getToken();
    return await ApiService.get(
      url: ApiEndpoints.myTransportBookings,
      token: token,
    );
  }
}