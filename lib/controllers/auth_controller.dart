import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/auth_models.dart';
import 'package:apnea_detector/models/user_profile.dart';
import 'package:apnea_detector/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final UserProfile? currentUser;
  final bool shouldCompleteProfile;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.currentUser,
    this.shouldCompleteProfile = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    UserProfile? currentUser,
    bool? shouldCompleteProfile,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      shouldCompleteProfile:
          shouldCompleteProfile ?? this.shouldCompleteProfile,
    );
  }

  static const initial = AuthState();
}

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthState state = AuthState.initial;

  AuthController({required this.authRepository});

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final hasToken = await authRepository.hasToken();
    if (!hasToken) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
        shouldCompleteProfile: false,
      );
      notifyListeners();
      return;
    }

    final result = await authRepository.getProfile();
    if (result is Ok<UserProfile>) {
      final user = result.value;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
        shouldCompleteProfile: !user.hasAnyProfileData,
        clearError: true,
      );
    } else {
      await authRepository.logout();
      final err = result as Err<UserProfile>;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
        shouldCompleteProfile: false,
        errorMessage: err.message,
      );
    }

    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await authRepository.login(
      username: username,
      password: password,
    );

    if (result is Ok<AuthResponse>) {
      final auth = result.value;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: auth.user,
        shouldCompleteProfile: !auth.user.hasAnyProfileData,
        clearError: true,
      );
      notifyListeners();
      return true;
    } else {
      final err = result as Err<AuthResponse>;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: err.message,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAndLogin({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final registerResult = await authRepository.register(
      username: username,
      password: password,
    );

    if (registerResult is Err<UserProfile>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: registerResult.message,
      );
      notifyListeners();
      return false;
    }

    final loginResult = await authRepository.login(
      username: username,
      password: password,
    );

    if (loginResult is Ok<AuthResponse>) {
      final auth = loginResult.value;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: auth.user,
        shouldCompleteProfile: true,
        clearError: true,
      );
      notifyListeners();
      return true;
    } else {
      final err = loginResult as Err<AuthResponse>;
      state = state.copyWith(
        isLoading: false,
        errorMessage: err.message,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveProfile({
    String? name,
    double? height,
    double? weight,
    int? age,
    int? sleepTarget,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await authRepository.updateProfile(
      name: name,
      height: height,
      weight: weight,
      age: age,
      sleepTarget: sleepTarget,
    );

    if (result is Ok<UserProfile>) {
      final user = result.value;
      state = state.copyWith(
        isLoading: false,
        currentUser: user,
        shouldCompleteProfile: false,
        isAuthenticated: true,
        clearError: true,
      );
      notifyListeners();
      return true;
    } else {
      final err = result as Err<UserProfile>;
      state = state.copyWith(
        isLoading: false,
        errorMessage: err.message,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    state = AuthState.initial;
    notifyListeners();
  }

  void skipProfileCompletion() {
    state = state.copyWith(shouldCompleteProfile: false);
    notifyListeners();
  }
}