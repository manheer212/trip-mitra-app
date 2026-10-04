import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_model.dart';

class TripService {
  // Use your local backend URL or production server URL here
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<TripResponse> generateTrip({
    required String destination,
    required int days,
    required String budget,
    required String interests,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-trip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'destination': destination,
        'days': days,
        'budget': budget,
        'interests': interests,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return TripResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['error'] ?? 'Failed to generate trip');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}