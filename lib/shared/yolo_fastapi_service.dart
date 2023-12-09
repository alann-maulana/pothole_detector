import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pothole_detector_flutter/env.dart';

final YoloFastApiService yoloFastApiService = YoloFastApiService(
  apiUrl: Env.kYoloFastApiUrl,
);

class YoloFastApiService {
  final String apiUrl;

  YoloFastApiService({required this.apiUrl});

  Future<Map<String, num>> objectDetectionJson(String filePath) async {
    final uri = Uri.parse('$apiUrl/img_object_detection_to_json');

    String imageType = '*';
    final split = filePath.split('.');
    if (split.isNotEmpty) {
      imageType = split.last;
    }

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('image', imageType),
        ),
      );
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final Map<String, num> predictions = {};
      final response = await http.Response.fromStream(streamedResponse);
      final map = jsonDecode(response.body);
      if (map['detect_objects'] is List) {
        final list = map['detect_objects'] as List;
        if (list.isNotEmpty) {
          for (var e in list) {
            if (e is Map) {
              predictions[e['name']] = e['confidence'];
            }
          }
        }
      }
      return predictions;
    }

    throw Exception(
      'Gagal mendapatkan data. Status code: ${streamedResponse.statusCode}',
    );
  }

  Future<XFile> objectDetectionFile(String filePath) async {
    final uri = Uri.parse('$apiUrl/img_object_detection_to_img');

    String imageType = '*';
    final split = filePath.split('.');
    if (split.isNotEmpty) {
      imageType = split.last;
    }

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('image', imageType),
        ),
      );
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      return XFile.fromData(response.bodyBytes);
    }

    throw Exception(
      'Gagal mendapatkan data. Status code: ${streamedResponse.statusCode}',
    );
  }
}
