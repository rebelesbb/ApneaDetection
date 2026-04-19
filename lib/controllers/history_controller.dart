import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:flutter/material.dart';

class HistoryState {
  final bool isLoading;
  final String? errorMessage;
  final DateTime focusedMonth;
  final List<Spo2SessionRecord> sessions;

  const HistoryState({
    this.isLoading = false,
    this.errorMessage,
    required this.focusedMonth,
    this.sessions = const [],
  });

  HistoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    DateTime? focusedMonth,
    List<Spo2SessionRecord>? sessions,
    bool clearError = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      sessions: sessions ?? this.sessions,
    );
  }

  factory HistoryState.initial() {
    final now = DateTime.now();
    return HistoryState(
      focusedMonth: DateTime(now.year, now.month, 1),
    );
  }
}

class HistoryController extends ChangeNotifier {
  final SleepRepository sleepRepository;
  late HistoryState state;

  HistoryController({required this.sleepRepository}) {
    state = HistoryState.initial();
  }

  Future<void> loadMonth(DateTime month) async {
    final focusedMonth = DateTime(month.year, month.month, 1);

    state = state.copyWith(
      isLoading: true,
      focusedMonth: focusedMonth,
      clearError: true,
    );
    notifyListeners();

    final monthStart = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final monthEnd =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0, 23, 59, 59);

    final result = await sleepRepository.getSessions(
      dateFrom: monthStart,
      dateTo: monthEnd,
    );

    if (result is Ok<List<Spo2SessionRecord>>) {
      state = state.copyWith(
        isLoading: false,
        sessions: result.value,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Err<List<Spo2SessionRecord>>).message,
      );
    }

    notifyListeners();
  }

  Future<void> updateRecord(Spo2SessionRecord record) async {
    final result = await sleepRepository.updateSession(record);

    if (result is Ok<Spo2SessionRecord>) {
      final updated = result.value;

      state = state.copyWith(
        sessions: state.sessions.map((s) {
          return s.id == updated.id ? updated : s;
        }).toList(),
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