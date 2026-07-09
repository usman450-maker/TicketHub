import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'local_notification_service.dart';
import 'storage_service.dart';

class NotificationService {
  static Future<Map<String, dynamic>> getNotifications() async {
    final token = await StorageService.getToken();
    return await ApiService.get(
      url: ApiEndpoints.notifications,
      token: token,
    );
  }

  static Future<void> markAsRead(int id) async {
    final token = await StorageService.getToken();
    await ApiService.put(
      url: ApiEndpoints.readNotification(id),
      token: token,
      body: {},
    );
  }

  static Future<void> markAllAsRead() async {
    final token = await StorageService.getToken();
    await ApiService.put(
      url: ApiEndpoints.readAllNotifications,
      token: token,
      body: {},
    );
  }

  static Future<void> clearAll() async {
    final token = await StorageService.getToken();
    await ApiService.delete(
      url: ApiEndpoints.clearNotifications,
      token: token,
      body: {},
    );
  }

  static Future<void> showBookingNotification({
    required String title,
    required String message,
  }) async {
    await LocalNotificationService.showNotification(
      title: title,
      body: message,
      type: 'booking',
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String message,
    String? type,
  }) async {
    await LocalNotificationService.showNotification(
      title: title,
      body: message,
      type: type,
    );
  }
}