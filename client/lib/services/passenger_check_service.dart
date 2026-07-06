import '../core/network/api_endpoints.dart';
import '../models/transport_booking.dart';
import 'api_service.dart';
import 'storage_service.dart';

class PassengerCheckService {
  // Check if any passenger already booked on this bus
  static Future<List<String>> checkAlreadyBooked({
    required String operatorNumber,
    required String departureDate,
    required String departureTime,
    required List<Passenger> passengers,
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

    if (response['success'] == true && response['bookedCNICs'] != null) {
      final bookedCNICs = List<String>.from(response['bookedCNICs']);
      
      // Find which current passengers are already booked
      final alreadyBooked = <String>[];
      for (var p in passengers) {
        final cleanCNIC = p.idNumber.replaceAll('-', '');
        if (bookedCNICs.contains(cleanCNIC)) {
          alreadyBooked.add(p.fullName);
        }
      }
      return alreadyBooked;
    }
    return [];
  }
}