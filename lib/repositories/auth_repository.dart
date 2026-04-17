import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/auth_models.dart';
import 'package:apnea_detector/models/user_profile.dart';
import 'package:apnea_detector/services/auth_api_service.dart';
import 'package:apnea_detector/services/local/auth_storage.dart';

class AuthRepository {
  final AuthApiService authApiService;
  final AuthStorageService authStorageService;

  AuthRepository({
    required this.authApiService,
    required this.authStorageService,
  });

  Future<Result<UserProfile>> register({
    required String username,
    required String password,
  }) async {
    try {
      final user = await authApiService.register(
        RegisterRequest(username: username, password: password),
      );
      return Ok(user);
    } catch (e) {
      return Err('Register failed: $e');
    }
  }

  Future<Result<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final authResponse = await authApiService.login(
        LoginRequest(username: username, password: password),
      );

      await authStorageService.saveAccessToken(authResponse.accessToken);
      return Ok(authResponse);
    } catch (e) {
      return Err('Login failed: $e');
    }
  }

  Future<Result<UserProfile>> getProfile() async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final user = await authApiService.getProfile(token);
      return Ok(user);
    } catch (e) {
      return Err('Failed to fetch current user: $e');
    }
  }

  Future<Result<UserProfile>> updateProfile({
    String? name,
    double? height,
    double? weight,
    int? age,
    int? sleepTarget,
  }) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final user = await authApiService.updateProfile(
        accessToken: token,
        request: UpdateUserProfileRequest(
          name: name,
          height: height,
          weight: weight,
          age: age,
          sleepTarget: sleepTarget,
        ),
      );

      return Ok(user);
    } catch (e) {
      return Err('Failed to update profile: $e');
    }
  }

  Future<bool> hasToken() async {
    final token = await authStorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await authStorageService.clearAccessToken();
  }
}