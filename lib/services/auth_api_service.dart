import 'dart:convert';

import 'package:apnea_detector/models/auth_models.dart';
import 'package:apnea_detector/models/user_profile.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  final String baseUrl;

  AuthApiService({required this.baseUrl});

  Future<UserProfile> register(RegisterRequest request) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponse.fromJson(json);
  }

  Future<UserProfile> getProfile(String accessToken) async {
    final uri = Uri.parse('$baseUrl/auth/profile');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  Future<UserProfile> updateProfile({
    required String accessToken,
    required UpdateUserProfileRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl/users/profile');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) {
        return json['detail']?.toString() ?? 'Unknown error';
      }
      return 'Unknown error';
    } catch (_) {
      return response.body;
    }
  }
}