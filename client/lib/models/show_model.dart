class Show {
  final int id;
  final int movieId;
  final String movieTitle;
  final String moviePoster;
  final String venueName;
  final String venueLocation;
  final int screenNumber;
  final String showDate;
  final String showTime;

  Show({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.moviePoster,
    required this.venueName,
    required this.venueLocation,
    required this.screenNumber,
    required this.showDate,
    required this.showTime,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'] ?? 0,
      movieId: json['movie_id'] ?? 0,
      movieTitle: json['movie_title'] ?? '',
      moviePoster: json['movie_poster'] ?? '',
      venueName: json['venue_name'] ?? '',
      venueLocation: json['venue_location'] ?? '',
      screenNumber: json['screen_number'] ?? 1,
      showDate: json['show_date'] ?? '',
      showTime: json['show_time'] ?? '',
    );
  }
}