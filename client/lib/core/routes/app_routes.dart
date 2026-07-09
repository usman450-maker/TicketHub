import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/signup_otp_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/auth/google_device_waiting_screen.dart';
import '../../screens/auth/google_signup_otp_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/movie/movies_screen.dart';
import '../../screens/movie/movie_detail_screen.dart';
import '../../screens/movie/select_showtime_screen.dart';
import '../../screens/movie/seat_selection_screen.dart';
import '../../screens/movie/booking_summary_screen.dart';
import '../../screens/movie/payment_screen.dart';
import '../../screens/movie/booking_confirmed_screen.dart';
import '../../models/booking_data.dart';
import 'route_names.dart';
import '../../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==========================
      // AUTH & ONBOARDING
      // ==========================
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case RouteNames.signupOtp:
        return MaterialPageRoute(builder: (_) => const SignupOtpScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteNames.otpVerification:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());

      case RouteNames.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case RouteNames.googleDeviceWaiting:
        return MaterialPageRoute(
            builder: (_) => const GoogleDeviceWaitingScreen());

      case RouteNames.googleSignupOtp:
        return MaterialPageRoute(
            builder: (_) => const GoogleSignupOtpScreen());

      // ==========================
      // HOME
      // ==========================
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // ==========================
      // MOVIE BOOKING FLOW
      // ==========================
      case RouteNames.movies:
        return MaterialPageRoute(builder: (_) => const MoviesScreen());

      case RouteNames.movieDetail:
        final movieId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movieId: movieId),
        );

      case RouteNames.selectShowtime:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SelectShowtimeScreen(
            movieId: args['movieId'],
            movieTitle: args['title'],
            moviePoster: args['poster'] ?? '',
            movieBackdrop: args['backdrop'] ?? '',
          ),
        );

      case RouteNames.seatSelection:
        final booking = settings.arguments as BookingData;
        return MaterialPageRoute(
          builder: (_) => SeatSelectionScreen(booking: booking),
        );

      case RouteNames.bookingSummary:
        final booking = settings.arguments as BookingData;
        return MaterialPageRoute(
          builder: (_) => BookingSummaryScreen(booking: booking),
        );

      case RouteNames.payment:
        final booking = settings.arguments as BookingData;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(booking: booking),
        );

      case RouteNames.bookingConfirmed:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmedScreen(
            booking: args['booking'],
            orderNumber: args['orderNumber'],
          ),
        );

        case '/notifications':
  return MaterialPageRoute(
    builder: (_) => const NotificationsScreen(),
    settings: settings,
  );

      // ==========================
      // DEFAULT (404)
      // ==========================
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}