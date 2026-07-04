import '../core/network/api_endpoints.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // ==========================
  // SIGNUP FLOW
  // ==========================

  // Step 1: Send OTP for signup
  static Future<Map<String, dynamic>> sendSignupOtp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await ApiService.post(
      url: ApiEndpoints.sendSignupOtp,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    // Save signup data locally until OTP is verified
    if (response['success'] == true) {
      await StorageService.savePendingSignup({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
    }

    return response;
  }

  // Step 2: Verify OTP and create account
  static Future<Map<String, dynamic>> verifySignupOtp({
    required String otp,
  }) async {
    final pending = await StorageService.getPendingSignup();

    if (pending == null) {
      return {
        'success': false,
        'message': 'Signup session expired. Please try again.',
      };
    }

    final response = await ApiService.post(
      url: ApiEndpoints.verifySignupOtp,
      body: {
        'name': pending['name'],
        'email': pending['email'],
        'phone': pending['phone'],
        'password': pending['password'],
        'otp': otp,
      },
    );

    if (response['success'] == true) {
      if (response['token'] != null) {
        await StorageService.saveToken(response['token']);
      }
      if (response['user'] != null) {
        await StorageService.saveUser(response['user']);
      }
      // Clear pending data
      await StorageService.clearPendingSignup();
    }

    return response;
  }

  // Step 3: Resend signup OTP
  static Future<Map<String, dynamic>> resendSignupOtp() async {
    final pending = await StorageService.getPendingSignup();

    if (pending == null) {
      return {
        'success': false,
        'message': 'Signup session expired. Please try again.',
      };
    }

    return await ApiService.post(
      url: ApiEndpoints.resendSignupOtp,
      body: {
        'name': pending['name'],
        'email': pending['email'],
      },
    );
  }

  // ==========================
  // LOGIN
  // ==========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      url: ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
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
  // FORGOT PASSWORD FLOW
  // ==========================
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await ApiService.post(
      url: ApiEndpoints.forgotPassword,
      body: {'email': email},
    );

    if (response['success'] == true) {
      await StorageService.saveResetEmail(email);
    }

    return response;
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await ApiService.post(
      url: ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp': otp},
    );
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    return await ApiService.post(
      url: ApiEndpoints.resendOtp,
      body: {'email': email},
    );
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      url: ApiEndpoints.resetPassword,
      body: {'email': email, 'newPassword': newPassword},
    );

    if (response['success'] == true) {
      await StorageService.clearResetEmail();
    }

    return response;
  }

  // LOGOUT
  static Future<void> logout() async {
    await StorageService.logout();
  }
}