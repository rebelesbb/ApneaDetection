import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:apnea_detector/utils/sleep_analytics_calculator.dart';
import 'package:flutter/material.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final Spo2SessionRecord? todaySession;
  final List<Spo2SessionRecord> allSessions;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.todaySession,
    this.allSessions = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    Spo2SessionRecord? todaySession,
    List<Spo2SessionRecord>? allSessions,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      todaySession: todaySession ?? this.todaySession,
      allSessions: allSessions ?? this.allSessions,
    );
  }

  static const initial = HomeState(isLoading: false, errorMessage: null, todaySession: null, allSessions: []);
}

class HomeController extends ChangeNotifier {
  final SleepRepository sleepRepository;
  HomeState state = HomeState.initial;

  HomeController({required this.sleepRepository});

  DateTime _selectedWeekStart = _startOfWeek(DateTime.now());
  DateTime get selectedWeekStart => _selectedWeekStart;

  void load() async{
    state = state.copyWith(isLoading: true, errorMessage: null);

    final s = sleepRepository.getTodaySession();
    final all = sleepRepository.getAllSessions();
    state = state.copyWith(isLoading: false, errorMessage: null, todaySession: s, allSessions: all);

    notifyListeners();
  }

  Future<void> updateRecord(Spo2SessionRecord record) async {
    final index = state.allSessions.indexWhere((s) => s.id == record.id);
    if(index != -1){
      state.allSessions[index] = record;
      sleepRepository.updateSession(record);
      notifyListeners();
    }
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

  static DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  List<Spo2SessionRecord> get sessionsForSelectedWeek {
    final weekEnd = _selectedWeekStart.add(const Duration(days: 7));
    return state.allSessions.where((s) {
      return s.startTime.isAfter(_selectedWeekStart.subtract(const Duration(seconds: 1))) &&
          s.startTime.isBefore(weekEnd);
    }).toList();
  }

  void changeWeek(int weeks) {
    _selectedWeekStart = _selectedWeekStart.add(Duration(days: weeks * 7));
    notifyListeners();
  }

  double computeCorerelation(bool Function(Spo2SessionRecord) condition) {
    final weekData = sessionsForSelectedWeek;
    return SleepAnalyticsCalculator.calculateCorrelationScore(sessions: weekData, condition: condition);
  }
}

