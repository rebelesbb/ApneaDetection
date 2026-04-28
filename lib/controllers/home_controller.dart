import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:flutter/material.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final Spo2SessionRecord? todaySession;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.todaySession,
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    Spo2SessionRecord? todaySession,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      todaySession: todaySession ?? this.todaySession,
    );
  }

  static const initial = HomeState();
}

class HomeController extends ChangeNotifier {
  final SleepRepository sleepRepository;
  HomeState state = HomeState.initial;

  HomeController({required this.sleepRepository});

  Future<void> loadTodaySession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await sleepRepository.getTodaySession();
    print(result);

    if (result is Ok<Spo2SessionRecord?>) {
      state = state.copyWith(
        isLoading: false,
        todaySession: result.value,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Err<Spo2SessionRecord?>).message,
      );
      print(state.errorMessage);
    }

    notifyListeners();
  }

  Future<bool> runAnalyze(DateTime startTime, DateTime endTime) async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final res = await sleepRepository.analyzeSleep(
      startTime: startTime,
      endTime: endTime,
    );

    if (res is Ok<Spo2SessionRecord>) {
      state = state.copyWith(
        isLoading: false,
        todaySession: res.value,
        clearError: true,
      );
      notifyListeners();
      return true;
    } else {
      final err = res as Err<Spo2SessionRecord>;
      state = state.copyWith(
        isLoading: false,
        errorMessage: err.message,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> updateRecord(Spo2SessionRecord record) async {
    final result = await sleepRepository.updateSession(record);

    if (result is Ok<Spo2SessionRecord>) {
      state = state.copyWith(
        todaySession: result.value,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        errorMessage: (result as Err<Spo2SessionRecord>).message,
      );
    }

    notifyListeners();
  }
}