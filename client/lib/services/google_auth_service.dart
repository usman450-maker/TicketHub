import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class GoogleAuthService {
  // ⚠️ Replace with your actual Web Client ID from Google Cloud Console
  static const String _webClientId =
      '\';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: kIsWeb ? null : _webClientId,
    clientId: kIsWeb ? _webClientId : null,
  );

  // ==========================
  // GOOGLE LOGIN
  // (Only for existing accounts)
  // ==========================
  static Future<Map<String, dynamic>> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      await _googleSignIn.signOut(); // Clean session

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in cancelled'};
      }

      // Check if account exists on backend
      final response = await ApiService.post(
        url: ApiEndpoints.googleLoginCheck,
        body: {'email': googleUser.email},
      );

      if (response['success'] == true) {
        if (response['token'] != null) {
          await StorageService.saveToken(response['token']);
        }
        if (response['user'] != null) {
          await StorageService.saveUser(response['user']);
        }
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Google login failed: ${e.toString()}',
      };
    }
  }

  // ==========================
  // GOOGLE SIGNUP - STEP 1
  // (Pick email from Google)
  // ==========================
  static Future<Map<String, dynamic>> pickGoogleEmail() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      await _googleSignIn.signOut(); // Clean session

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign up cancelled'};
      }

      return {
        'success': true,
        'email': googleUser.email,
        'name': googleUser.displayName ?? 'User',
        'photo': googleUser.photoUrl,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get Google account: ${e.toString()}',
      };
    }
  }

  // ==========================
  // GOOGLE SIGNUP - STEP 2
  // (Send device authorization email)
  // ==========================
  static Future<Map<String, dynamic>> sendDeviceAuthorization({
    required String email,
    required String name,
  }) async {
    String deviceInfo = 'Unknown Device';
    if (kIsWeb) {
      deviceInfo = 'Web Browser';
    } else {
      deviceInfo = 'Mobile Device';
    }

    return await ApiService.post(
      url: ApiEndpoints.sendDeviceAuth,
      body: {
        'email': email,
        'name': name,
        'deviceInfo': deviceInfo,
      },
    );
  }

  // ==========================
  // GOOGLE SIGNUP - STEP 3
  // (Check if user allowed the device)
  // ==========================
  static Future<Map<String, dynamic>> checkDeviceStatus({
    required String email,
  }) async {
    return await ApiService.post(
      url: ApiEndpoints.checkDeviceStatus,
      body: {'email': email},
    );
  }

  // ==========================
  // GOOGLE SIGNUP - STEP 4
  // (Verify OTP & create account)
  // ==========================
  static Future<Map<String, dynamic>> verifyOtpAndCreateAccount({
    required String name,
    required String email,
    required String otp,
  }) async {
    final response = await ApiService.post(
      url: ApiEndpoints.verifyGoogleSignupOtp,
      body: {'name': name, 'email': email, 'otp': otp},
    );

    if (response['success'] == true) {
      if (response['token'] != null) {
        await StorageService.saveToken(response['token']);
      }
      if (response['user'] != null) {
        await StorageService.saveUser(response['user']);
      }
    }

    return response;
  }

  // ==========================
  // RESEND OTP (NEW)
  // ==========================
  static Future<Map<String, dynamic>> resendGoogleSignupOtp({
    required String email,
    required String name,
  }) async {
    return await ApiService.post(
      url: ApiEndpoints.resendGoogleSignupOtp,
      body: {'email': email, 'name': name},
    );
  }

  // ==========================
  // SIGN OUT
  // ==========================
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }
}