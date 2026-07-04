import '../core/network/api_endpoints.dart';
import '../models/show_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ShowService {
  // Generate/get shows for a movie at a venue
  static Future<List<Show>> generateShows({
    required int movieId,
    required String movieTitle,
    required String moviePoster,
    required String venueName,
    required String venueLocation,
    required String showDate,
  }) async {
    final token = await StorageService.getToken();

    final response = await ApiService.post(
      url: ApiEndpoints.generateShows,
      token: token,
      body: {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'moviePoster': moviePoster,
        'venueName': venueName,
        'venueLocation': venueLocation,
        'showDate': showDate,
      },
    );

    if (response['success'] == true && response['shows'] != null) {
      return (response['shows'] as List)
          .map((s) => Show.fromJson(s))
          .toList();
    }
    return [];
  }

  // Get all shows at a venue on a date (all movies)
  static Future<List<Show>> getShowsAtVenue({
    required String venueName,
    required String showDate,
  }) async {
    final token = await StorageService.getToken();

    final response = await ApiService.post(
      url: ApiEndpoints.venueShows,
      token: token,
      body: {
        'venueName': venueName,
        'showDate': showDate,
      },
    );

    if (response['success'] == true && response['shows'] != null) {
      return (response['shows'] as List)
          .map((s) => Show.fromJson(s))
          .toList();
    }
    return [];
  }
}