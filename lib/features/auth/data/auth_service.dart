import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://fix-my-device-backend.onrender.com';

  static String? token;
  static String? email;
  static String? agentSetupCode;
  static final ValueNotifier<int> authState = ValueNotifier<int>(0);

  Future<bool> register(String userEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': userEmail,
        'password': password,
      }),
    );

    debugPrint('Register response status: ${response.statusCode}');
    debugPrint('Register response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    try {
      final dynamic data = jsonDecode(response.body);
      final String? message = data is Map<String, dynamic>
          ? data['message']?.toString()
          : null;

      if (message == 'User registered successfully') {
        return true;
      }
    } catch (_) {
      if (response.body.contains('User registered successfully')) {
        return true;
      }
    }

    return false;
  }

  Future<bool> login(String userEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': userEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];
      email = data['email'];
      agentSetupCode = data['agentSetupCode']?.toString();
      authState.value++;
      return true;
    }

    return false;
  }

  static String? getToken() => token;
  static String? getEmail() => email;
  static String? getAgentSetupCode() => agentSetupCode;
  static bool get isLoggedIn =>
      token != null && token!.isNotEmpty && email != null && email!.isNotEmpty;

  static void logout() {
    token = null;
    email = null;
    agentSetupCode = null;
    authState.value++;
  }
}
