import 'dart:convert';

import 'package:apnea_detector/models/sleep_api_models.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:http/http.dart' as http;

class SleepApiService {
  final String baseUrl;

  SleepApiService({required this.baseUrl});

  Future<Spo2SessionRecord?> getTodaySession(String accessToken) async {
    final uri = Uri.parse('$baseUrl/sessions/today');

    final response = await http.get(
      uri,
      headers: _headers(accessToken),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    if (response.body.trim().isEmpty || response.body.trim() == 'null') {
      return null;
    }

    final json = jsonDecode(response.body);
    if (json == null) return null;

    return Spo2SessionRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Spo2SessionRecord>> getSessions({
    required String accessToken,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final queryParams = <String, String>{};

    if (dateFrom != null) {
      queryParams['date_from'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      queryParams['date_to'] = dateTo.toIso8601String();
    }

    final uri =
        Uri.parse('$baseUrl/sessions').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _headers(accessToken),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as List;
    return json
        .map((e) => Spo2SessionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Spo2SessionRecord> analyzeSession({
    required String accessToken,
    required AnalyzeSpo2SessionRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl/sessions/analyze');

    final response = await http.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Spo2SessionRecord.fromJson(json);
  }

  Future<Spo2SessionRecord> updateSessionFlags({
    required String accessToken,
    required int sessionId,
    required UpdateSessionFlagsRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl/sessions/$sessionId');

    final response = await http.put(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Spo2SessionRecord.fromJson(json);
  }

  Future<WeeklyInsightsResponse> getWeeklyInsights({
    required String accessToken,
    required DateTime startDate,
  }) async {
    final uri = Uri.parse('$baseUrl/insights/weekly').replace(
      queryParameters: {
        'start_date': startDate.toIso8601String(),
      },
    );

    final response = await http.get(
      uri,
      headers: _headers(accessToken),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeeklyInsightsResponse.fromJson(json);
  }

  Map<String, String> _headers(String accessToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ?? 'Unknown error';
    } catch (_) {
      return response.body;
    }
  }
}