import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // ⚠️ Your PC IP address (find with: ipconfig)
  static const String _'; // Change to YOUR IP

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://$_pcIp:5000/api';
  }

  // ==========================
  // AUTH - SIGNUP FLOW
  // ==========================
  static String get sendSignupOtp => '$baseUrl/auth/send-signup-otp';
  static String get verifySignupOtp => '$baseUrl/auth/verify-signup-otp';
  static String get resendSignupOtp => '$baseUrl/auth/resend-signup-otp';

  // ==========================
  // AUTH - LOGIN
  // ==========================
  static String get login => '$baseUrl/auth/login';

  // ==========================
  // AUTH - FORGOT PASSWORD FLOW
  // ==========================
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get resendOtp => '$baseUrl/auth/resend-otp';
  static String get resetPassword => '$baseUrl/auth/reset-password';

  // ==========================
  // GOOGLE SIGN-IN FLOW
  // ==========================
  static String get googleLoginCheck => '$baseUrl/auth/google-login-check';
  static String get sendDeviceAuth => '$baseUrl/auth/send-device-authorization';
  static String get checkDeviceStatus => '$baseUrl/auth/check-device-status';
  static String get verifyGoogleSignupOtp => '$baseUrl/auth/verify-google-signup-otp';
  static String get resendGoogleSignupOtp => '$baseUrl/auth/resend-google-signup-otp';
  // Add these
static String get bookedSeats => '$baseUrl/bookings/booked-seats';
static String get createPaymentIntent => '$baseUrl/bookings/create-payment-intent';
static String get confirmBooking => '$baseUrl/bookings/confirm';
static String get myBookings => '$baseUrl/bookings/my-bookings'; // ← NEW


// Parks
static String get parks => '$baseUrl/parks';
static String get parkPaymentIntent => '$baseUrl/parks/payment-intent';
static String get confirmParkBooking => '$baseUrl/parks/confirm';
static String get myParkBookings => '$baseUrl/parks/bookings/my';


// Notifications
static String get notifications => '$baseUrl/notifications';
static String get readAllNotifications => '$baseUrl/notifications/read-all';
static String get clearNotifications => '$baseUrl/notifications/clear';
static String readNotification(int id) => '$baseUrl/notifications/read/$id';

  // ==========================
  // PROFILE
  // ==========================
  static String get profile => '$baseUrl/auth/profile';
  static String get updateProfile => '$baseUrl/auth/update-profile';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get deleteAccount => '$baseUrl/auth/delete-account';

static String get generateShows => '$baseUrl/shows/generate';
static String get venueShows => '$baseUrl/shows/venue-shows';


// Transport endpoints
static String get transportPaymentIntent => '$baseUrl/transport/payment-intent';
static String get transportBookedSeats => '$baseUrl/transport/booked-seats';
static String get confirmTransportBooking => '$baseUrl/transport/confirm';
static String get myTransportBookings => '$baseUrl/transport/my-bookings';


// Refunds
static String get requestRefund => '$baseUrl/refunds/request';
static String get myRefunds => '$baseUrl/refunds/my-refunds';

  static const String tmdbApa'; // ⚠️ Paste your TMDB key
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbImageOriginal = 'https://image.tmdb.org/t/p/original';

  // Movie endpoints
  static String tmdbNowPlaying({int page = 1}) =>
      '$tmdbBaseUrl/movie/now_playing?api_key=$tmdbApiKey&page=$page';
  static String tmdbPopular({int page = 1}) =>
      '$tmdbBaseUrl/movie/popular?api_key=$tmdbApiKey&page=$page';
  static String tmdbUpcoming({int page = 1}) =>
      '$tmdbBaseUrl/movie/upcoming?api_key=$tmdbApiKey&page=$page';
  static String tmdbTopRated({int page = 1}) =>
      '$tmdbBaseUrl/movie/top_rated?api_key=$tmdbApiKey&page=$page';
  static String tmdbGenres() =>
      '$tmdbBaseUrl/genre/movie/list?api_key=$tmdbApiKey';
  static String tmdbMoviesByGenre(int genreId, {int page = 1}) =>
      '$tmdbBaseUrl/discover/movie?api_key=$tmdbApiKey&with_genres=$genreId&page=$page';
  static String tmdbMovieDetails(int movieId) =>
      '$tmdbBaseUrl/movie/$movieId?api_key=$tmdbApiKey';
  static String tmdbMovieVideos(int movieId) =>
      '$tmdbBaseUrl/movie/$movieId/videos?api_key=$tmdbApiKey';
  static String tmdbMovieCredits(int movieId) =>
      '$tmdbBaseUrl/movie/$movieId/credits?api_key=$tmdbApiKey';

}