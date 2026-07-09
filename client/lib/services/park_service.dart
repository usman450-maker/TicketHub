import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ParkService {
  static Future<List<Map<String, dynamic>>> getParks({String? city}) async {
    final token = await StorageService.getToken();
    final url = city != null
        ? '${ApiEndpoints.parks}?city=$city'
        : ApiEndpoints.parks;

    final response = await ApiService.get(url: url, token: token);

    if (response['success'] == true && response['parks'] != null) {
      return List<Map<String, dynamic>>.from(response['parks']);
    }
    return [];
  }

  static Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    final token = await StorageService.getToken();
    return await ApiService.post(
      url: ApiEndpoints.parkPaymentIntent,
      token: token,
      body: {'amount': amount},
    );
  }

  static Future<Map<String, dynamic>> confirmBooking(
      Map<String, dynamic> data, String paymentId) async {
    final token = await StorageService.getToken();
    return await ApiService.post(
      url: ApiEndpoints.confirmParkBooking,
      token: token,
      body: {...data, 'paymentId': paymentId},
    );
  }

  static Future<Map<String, dynamic>> getMyBookings() async {
    final token = await StorageService.getToken();
    return await ApiService.get(
      url: ApiEndpoints.myParkBookings,
      token: token,
    );
  }
}