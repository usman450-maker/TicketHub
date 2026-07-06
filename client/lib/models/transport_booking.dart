class TransportBooking {
  final String transportType;
  final String operatorName;
  final String operatorNumber;
  final String fromLocation;
  final String toLocation;
  final String departureDate;
  final String departureTime;
  final String? arrivalTime;
  final String? duration;
  final String? classType;
  final List<String> seatNumbers;
  final Map<String, String> seatGenderMap; // { 'A1': 'Male', 'A2': 'Female' }
  final List<Passenger> passengers;
  final double pricePerPassenger;

  TransportBooking({
    required this.transportType,
    required this.operatorName,
    required this.operatorNumber,
    required this.fromLocation,
    required this.toLocation,
    required this.departureDate,
    required this.departureTime,
    this.arrivalTime,
    this.duration,
    this.classType,
    this.seatNumbers = const [],
    this.seatGenderMap = const {},
    this.passengers = const [],
    required this.pricePerPassenger,
  });

   double get basePrice => pricePerPassenger * (passengers.isEmpty ? 1 : passengers.length);
  double get bookingFee => basePrice * 0.05;
  double get tax => basePrice * 0.10;
  double get totalAmount => basePrice + bookingFee + tax;
  


  TransportBooking copyWith({
    List<String>? seatNumbers,
    Map<String, String>? seatGenderMap,
    List<Passenger>? passengers,
  }) {
    return TransportBooking(
      transportType: transportType,
      operatorName: operatorName,
      operatorNumber: operatorNumber,
      fromLocation: fromLocation,
      toLocation: toLocation,
      departureDate: departureDate,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      duration: duration,
      classType: classType,
      seatNumbers: seatNumbers ?? this.seatNumbers,
      seatGenderMap: seatGenderMap ?? this.seatGenderMap,
      passengers: passengers ?? this.passengers,
      pricePerPassenger: pricePerPassenger,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transportType': transportType,
      'operatorName': operatorName,
      'operatorNumber': operatorNumber,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'classType': classType,
      'seatNumbers': seatNumbers,
      'seatGenderMap': seatGenderMap,
      'passengerDetails': passengers.map((p) => p.toJson()).toList(),
      'basePrice': basePrice,
      'bookingFee': bookingFee,
      'tax': tax,
      'totalAmount': totalAmount,
    };
  }
}

class Passenger {
  final String fullName;
  final String idNumber;
  final String gender;
  final int age;
  final String nationality;
  final String email;
  final String phone;

  Passenger({
    required this.fullName,
    required this.idNumber,
    required this.gender,
    required this.age,
    required this.nationality,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'idNumber': idNumber,
      'gender': gender,
      'age': age,
      'nationality': nationality,
      'email': email,
      'phone': phone,
    };
  }
}