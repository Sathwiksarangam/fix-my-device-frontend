import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../auth/data/auth_service.dart';

class ApiDeviceService {
  final String baseUrl = 'https://fix-my-device-backend.onrender.com';

  Future<List<dynamic>> getDevices() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/devices'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load devices: ${response.statusCode}');
    }
  }
}