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
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      todaySession: todaySession ?? this.todaySession,
    );
  }

  static const initial = HomeState(isLoading: false, errorMessage: null, todaySession: null);
}

class HomeController extends ChangeNotifier {
  final SleepRepository sleepRepository;
  HomeState state = HomeState.initial;

  HomeController({required this.sleepRepository});

  void load() async{
    state = state.copyWith(isLoading: true, errorMessage: null);

    final hasPermission = await sleepRepository.healthService.requestPermissions();

    if(hasPermission) {
      final s = sleepRepository.getTodaySession();
      state = state.copyWith(isLoading: false, errorMessage: null, todaySession: s);
    }
    else {
      state = state.copyWith(isLoading: false, errorMessage: "Health permissions not granted", todaySession: null);
    }

    notifyListeners();
  }

  Future<bool> runAnalyze(DateTime startTime, DateTime endTime) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    final res = await sleepRepository.analyzeSleep(startTime: startTime, endTime: endTime);

    if(res is Ok<Spo2SessionRecord>) {
      state = state.copyWith(isLoading: false, todaySession: res.value, errorMessage: null);
      notifyListeners();
      return true;
    }
    else {
      final err = res as Err<Spo2SessionRecord>;
      state = state.copyWith(isLoading: false, errorMessage: err.message, todaySession: null);
      notifyListeners();
      return false;
    }
  }
}

