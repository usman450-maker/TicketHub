import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transport_booking.dart';
import 'storage_service.dart';

class PassengerStorageService {
  static Future<String> _getKey() async {
    final user = await StorageService.getUser();
    final userId = user?['id']?.toString() ?? 'guest';
    return 'saved_passengers_$userId';
  }

  static Future<void> savePassenger(Passenger passenger) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final saved = await getSavedPassengers();

    final exists = saved.any((p) =>
        p.idNumber.replaceAll('-', '') ==
        passenger.idNumber.replaceAll('-', ''));

    if (!exists) {
      saved.add(passenger);
      final jsonList = saved.map((p) => p.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    }
  }

  static Future<List<Passenger>> getSavedPassengers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final data = prefs.getString(key);

    if (data == null) return [];

    try {
      final List<dynamic> list = jsonDecode(data);
      return list
          .map((json) => Passenger(
                fullName: json['fullName'] ?? '',
                idNumber: json['idNumber'] ?? '',
                gender: json['gender'] ?? 'Male',
                age: json['age'] ?? 0,
                nationality: json['nationality'] ?? '',
                email: json['email'] ?? '',
                phone: json['phone'] ?? '',
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> deletePassenger(String fullName, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final saved = await getSavedPassengers();

    saved.removeWhere((p) => p.fullName == fullName && p.phone == phone);

    final jsonList = saved.map((p) => p.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    await prefs.remove(key);
  }
}