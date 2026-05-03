import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiDeviceService {
  final String baseUrl = "https://fix-my-device-backend.onrender.com";

  Future<List<dynamic>> getDevices() async {
    final response = await http.get(Uri.parse('$baseUrl/api/devices'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load devices");
    }
  }
}