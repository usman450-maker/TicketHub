import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  // POST Request
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // GET Request
  static Future<Map<String, dynamic>> get({
    required String url,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic>
          ? data
          : {'success': false, 'message': 'Invalid response'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response',
      };
    }
  }

  // Error message
  static String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup')) {
      return 'No internet connection. Check your network.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timeout. Try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}