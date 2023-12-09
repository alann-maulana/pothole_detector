import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pothole_detector_flutter/env.dart';

final SupabaseService supabaseService = SupabaseService(
  apiUrl: Env.kSupabaseApiUrl,
  apiKey: Env.kSupabaseApiKey,
);

class SupabaseService {
  final String apiUrl;
  final String apiKey;

  SupabaseService({required this.apiUrl, required this.apiKey});

  Future<void> recordData(String location, String damageType) async {
    final url = Uri.parse('$apiUrl/rest/v1/pothole_data');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'location': location,
        'damage_type': damageType,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('Data recorded successfully.');
    } else {
      debugPrint('Failed to record data. Status code: ${response.statusCode}');
      debugPrint(response.body);
    }
  }
}
