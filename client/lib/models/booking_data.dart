class BookingData {
  final int movieId;
  final String movieTitle;
  final String moviePoster;
  final String movieBackdrop;
  final String venueName;
  final String venueLocation;
  final String showDate;
  final String showTime;
  final int? screenNumber;
  final int? showId;
  final List<SeatSelection> selectedSeats;

  BookingData({
    required this.movieId,
    required this.movieTitle,
    required this.moviePoster,
    required this.movieBackdrop,
    required this.venueName,
    required this.venueLocation,
    required this.showDate,
    required this.showTime,
    this.screenNumber,
    this.showId,
    this.selectedSeats = const [],
  });

  double get basePrice {
    double total = 0;
    for (var seat in selectedSeats) {
      total += seat.price;
    }
    return total;
  }

  double get bookingFee => basePrice * 0.05;
  double get tax => basePrice * 0.10;
  double get totalAmount => basePrice + bookingFee + tax;

  List<String> get seatIds => selectedSeats.map((s) => s.id).toList();

 BookingData copyWith({
    List<SeatSelection>? selectedSeats,
    int? screenNumber,
    int? showId,
  }) {
    return BookingData(
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      movieBackdrop: movieBackdrop,
      venueName: venueName,
      venueLocation: venueLocation,
      showDate: showDate,
      showTime: showTime,
      screenNumber: screenNumber ?? this.screenNumber,
      showId: showId ?? this.showId,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'movieId': movieId,
    'movieTitle': movieTitle,
    'moviePoster': moviePoster,
    'venueName': venueName,
    'venueLocation': venueLocation,
    'showDate': showDate,
    'showTime': showTime,
    'screenNumber': screenNumber,  // ← MUST INCLUDE
    'showId': showId,  // ← MUST INCLUDE
    'seats': seatIds,
    'basePrice': basePrice,
    'bookingFee': bookingFee,
    'tax': tax,
    'totalAmount': totalAmount,
  };
}
}


// Seat with tier & price info
class SeatSelection {
  final String id;
  final String tier;
  final double price;

  SeatSelection({
    required this.id,
    required this.tier,
    required this.price,
  });
}