import 'dart:typed_data';

import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/report_models.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ExportReportState {
  final bool isLoading;
  final String? errorMessage;

  const ExportReportState({
    this.isLoading = false,
    this.errorMessage,
  });

  ExportReportState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExportReportState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const initial = ExportReportState();
}

class ExportReportController extends ChangeNotifier {
  final SleepRepository sleepRepository;

  ExportReportState state = ExportReportState.initial;

  ExportReportController({required this.sleepRepository});

  Future<bool> generateAndOpenPdf({
    required DateTime startDate,
    required DateTime endDate,
    required ChartMode chartMode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await sleepRepository.generateSleepPdfReport(
      startDate: startDate,
      endDate: endDate,
      chartMode: chartMode,
    );

    if (result is Ok<Uint8List>) {
      state = state.copyWith(isLoading: false, clearError: true);
      notifyListeners();

      await Printing.layoutPdf(
        onLayout: (_) async => result.value,
      );

      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: (result as Err<Uint8List>).message,
      );
      notifyListeners();
      return false;
    }
  }
}