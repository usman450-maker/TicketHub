import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/network/api_endpoints.dart';
import '../models/movie_model.dart';

class MovieService {
  // Get Now Playing Movies
  static Future<List<Movie>> getNowPlaying() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.tmdbNowPlaying()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting now playing: $e');
      return [];
    }
  }

  // Get Popular Movies
  static Future<List<Movie>> getPopular() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.tmdbPopular()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting popular: $e');
      return [];
    }
  }

  // Get Upcoming Movies
  static Future<List<Movie>> getUpcoming() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.tmdbUpcoming()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting upcoming: $e');
      return [];
    }
  }

  // Get Top Rated
  static Future<List<Movie>> getTopRated() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.tmdbTopRated()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting top rated: $e');
      return [];
    }
  }

  // Get Genres
  static Future<List<Genre>> getGenres() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.tmdbGenres()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final genres = data['genres'] as List;
        return genres.map((json) => Genre.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting genres: $e');
      return [];
    }
  }

  // Get Movies by Genre
  static Future<List<Movie>> getMoviesByGenre(int genreId) async {
    try {
      final response =
          await http.get(Uri.parse(ApiEndpoints.tmdbMoviesByGenre(genreId)));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting movies by genre: $e');
      return [];
    }
  }

  // Get Movie Details (with cast + trailer)
  static Future<Movie?> getMovieDetails(int movieId) async {
    try {
      // Get basic details
      final detailsResponse =
          await http.get(Uri.parse(ApiEndpoints.tmdbMovieDetails(movieId)));

      // Get videos (trailer)
      final videosResponse =
          await http.get(Uri.parse(ApiEndpoints.tmdbMovieVideos(movieId)));

      // Get credits (cast)
      final creditsResponse =
          await http.get(Uri.parse(ApiEndpoints.tmdbMovieCredits(movieId)));

      if (detailsResponse.statusCode == 200) {
        final data = jsonDecode(detailsResponse.body);
        final movie = Movie.fromJson(data);

        // Add trailer
        String? trailerKey;
        if (videosResponse.statusCode == 200) {
          final videosData = jsonDecode(videosResponse.body);
          final videos = videosData['results'] as List;
          final trailer = videos.firstWhere(
            (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
            orElse: () => videos.isNotEmpty ? videos[0] : null,
          );
          if (trailer != null) {
            trailerKey = trailer['key'];
          }
        }

        // Add cast
        List<CastMember>? cast;
        if (creditsResponse.statusCode == 200) {
          final creditsData = jsonDecode(creditsResponse.body);
          final castList = creditsData['cast'] as List;
          cast = castList
              .take(10)
              .map((json) => CastMember.fromJson(json))
              .toList();
        }

        return Movie(
          id: movie.id,
          title: movie.title,
          overview: movie.overview,
          posterPath: movie.posterPath,
          backdropPath: movie.backdropPath,
          voteAverage: movie.voteAverage,
          releaseDate: movie.releaseDate,
          genreIds: movie.genreIds,
          runtime: movie.runtime,
          genres: movie.genres,
          cast: cast,
          trailerKey: trailerKey,
        );
      }
      return null;
    } catch (e) {
      print('Error getting movie details: $e');
      return null;
    }
  }
}