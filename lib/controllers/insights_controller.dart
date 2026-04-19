import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/sleep_api_models.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:flutter/material.dart';

class InsightsState {
  final bool isLoading;
  final String? errorMessage;
  final DateTime selectedWeekStart;
  final List<Spo2SessionRecord> sessions;
  final double smokingCorrelation;
  final double alcoholCorrelation;
  final int smokingDaysCount;
  final int alcoholDaysCount;

  const InsightsState({
    this.isLoading = false,
    this.errorMessage,
    required this.selectedWeekStart,
    this.sessions = const [],
    this.smokingCorrelation = 0,
    this.alcoholCorrelation = 0,
    this.smokingDaysCount = 0,
    this.alcoholDaysCount = 0,
  });

  InsightsState copyWith({
    bool? isLoading,
    String? errorMessage,
    DateTime? selectedWeekStart,
    List<Spo2SessionRecord>? sessions,
    double? smokingCorrelation,
    double? alcoholCorrelation,
    int? smokingDaysCount,
    int? alcoholDaysCount,
    bool clearError = false,
  }) {
    return InsightsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      sessions: sessions ?? this.sessions,
      smokingCorrelation: smokingCorrelation ?? this.smokingCorrelation,
      alcoholCorrelation: alcoholCorrelation ?? this.alcoholCorrelation,
      smokingDaysCount: smokingDaysCount ?? this.smokingDaysCount,
      alcoholDaysCount: alcoholDaysCount ?? this.alcoholDaysCount,
    );
  }

  factory InsightsState.initial() {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    return InsightsState(selectedWeekStart: startOfWeek);
  }
}

class InsightsController extends ChangeNotifier {
  final SleepRepository sleepRepository;
  late InsightsState state;

  InsightsController({required this.sleepRepository}) {
    state = InsightsState.initial();
  }

  Future<void> loadWeek(DateTime weekStart) async {
    final normalizedWeekStart = _startOfWeek(weekStart);

    state = state.copyWith(
      isLoading: true,
      selectedWeekStart: normalizedWeekStart,
      clearError: true,
    );
    notifyListeners();

    final result = await sleepRepository.getWeeklyInsights(
      startDate: normalizedWeekStart,
    );

    if (result is Ok<WeeklyInsightsResponse>) {
      final insights = result.value;
      state = state.copyWith(
        isLoading: false,
        sessions: insights.sessions,
        smokingCorrelation: insights.smokingCorrelation,
        alcoholCorrelation: insights.alcoholCorrelation,
        smokingDaysCount: insights.smokingDaysCount,
        alcoholDaysCount: insights.alcoholDaysCount,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Err<WeeklyInsightsResponse>).message,
      );
    }

    notifyListeners();
  }

  void changeWeek(int weeks) {
    final nextWeek = state.selectedWeekStart.add(Duration(days: weeks * 7));
    loadWeek(nextWeek);
  }

  static DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }
}