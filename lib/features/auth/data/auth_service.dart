import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://fix-my-device-backend.onrender.com';

  static String? token;
  static String? email;

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
      return true;
    }

    return false;
  }

  static String? getToken() {
    return token;
  }

  static void logout() {
    token = null;
    email = null;
  }
}