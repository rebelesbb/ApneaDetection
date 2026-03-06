import 'dart:convert';
import 'package:apnea_detector/models/spo2_predict_models.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl; // ex: http://10.0.2.2:8000 pentru emulator Android

  ApiService({required this.baseUrl});

  Future<Spo2PredictResponse> predictApnea(Spo2PredictRequest request) async {
    final uri = Uri.parse("$baseUrl/predict");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200) {
      try {
        final body = jsonDecode(res.body);
        final detail = body["detail"]?.toString() ?? "Unknown error";
        throw Exception("API error ${res.statusCode}: $detail");
      } catch (_) {
        throw Exception("API error ${res.statusCode}: ${res.body}");
      }
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return Spo2PredictResponse.fromJson(json);
  }
}