import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class RefundService {
  static Future<Map<String, dynamic>> requestRefund({
    required int bookingId,
    required String bookingType,
    required String orderNumber,
    required double originalAmount,
    required String reason,
    required String paymentId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    final token = await StorageService.getToken();
    return await ApiService.post(
      url: ApiEndpoints.requestRefund,
      token: token,
      body: {
        'bookingId': bookingId,
        'bookingType': bookingType,
        'orderNumber': orderNumber,
        'originalAmount': originalAmount,
        'reason': reason,
        'paymentId': paymentId,
        'bookingDate': bookingDate,
        'bookingTime': bookingTime,
      },
    );
  }

  static Future<Map<String, dynamic>> getMyRefunds() async {
    final token = await StorageService.getToken();
    return await ApiService.get(
      url: ApiEndpoints.myRefunds,
      token: token,
    );
  }
}