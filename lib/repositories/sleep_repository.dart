import 'dart:typed_data';
import 'package:apnea_detector/models/report_models.dart';
import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/sleep_api_models.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/services/local/auth_storage.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/sleep_api_service.dart';
import 'package:health/health.dart';
import 'dart:math';

class SleepRepository {
  final SleepApiService sleepApiService;
  final HealthService healthService;
  final AuthStorageService authStorageService;

  SleepRepository({
    required this.sleepApiService,
    required this.healthService,
    required this.authStorageService,
  });

  Future<Result<Spo2SessionRecord?>> getTodaySession() async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final session = await sleepApiService.getTodaySession(token);
      return Ok(session);
    } catch (e) {
      return Err('Failed to fetch today session: $e');
    }
  }

  Future<Result<List<Spo2SessionRecord>>> getSessions({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final sessions = await sleepApiService.getSessions(
        accessToken: token,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      return Ok(sessions);
    } catch (e) {
      return Err('Failed to fetch sessions: $e');
    }
  }

  Future<Result<Spo2SessionRecord>> updateSession(Spo2SessionRecord record) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final updated = await sleepApiService.updateSessionFlags(
        accessToken: token,
        sessionId: record.id,
        request: UpdateSessionFlagsRequest(
          hasSmoked: record.hasSmoked,
          hasDrunkAlcohol: record.hasDrunkAlcohol,
        ),
      );

      return Ok(updated);
    } catch (e) {
      return Err('Failed to update session: $e');
    }
  }

  Future<Result<Spo2SessionRecord>> analyzeSleep({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final ok = await healthService.requestPermissions();
      if (!ok) {
        return const Err("Health permissions denied");
      }

      final points = await healthService.fetchSpO2(startTime, endTime);
      if (points.isEmpty) {
        return const Err("No SpO2 data found for the given period");
      }

      final samples = points
          .map((p) => (
                time: p.dateFrom,
                value: (p.value as NumericHealthValue).numericValue.toDouble()
              ))
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));

      final data = prepareSpO2(samples);

      if (data.values.length < 120) {
        return const Err(
          "Not enough data points, at least 2 minutes of data are required",
        );
      }

      final sleepPoints = await healthService.fetchSleep(
        data.signalStart,
        data.signalEnd,
      );

      final stages = buildSleepStageVectorFromAwakePoints(
        sleepPoints: sleepPoints,
        signalStart: data.signalStart,
        length: data.values.length,
      );

      final session = await sleepApiService.analyzeSession(
        accessToken: token,
        request: AnalyzeSpo2SessionRequest(
          startTime: data.signalStart,
          endTime: data.signalEnd,
          spo2values: data.values,
          timestamps: data.timestamps,
          sleepStages: stages,
          hasSmoked: false,
          hasDrunkAlcohol: false,
        ),
      );

      return Ok(session);
    } catch (e) {
      return Err("Error during sleep analysis: $e");
    }
  }

  Future<Result<WeeklyInsightsResponse>> getWeeklyInsights({
    required DateTime startDate,
  }) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final insights = await sleepApiService.getWeeklyInsights(
        accessToken: token,
        startDate: startDate,
      );

      return Ok(insights);
    } catch (e) {
      return Err('Failed to fetch weekly insights: $e');
    }
  }

  Future<Result<Uint8List>> generateSleepPdfReport({
    required DateTime startDate,
    required DateTime endDate,
    required ChartMode chartMode,
  }) async {
    try {
      final token = await authStorageService.getAccessToken();
      if (token == null) {
        return const Err('No access token found');
      }

      final bytes = await sleepApiService.generateSleepPdfReport(
        accessToken: token,
        request: SleepReportRequest(
          startDate: startDate,
          endDate: endDate,
          chartMode: chartMode,
        ),
      );

      return Ok(bytes);
    } catch (e) {
      return Err('Failed to generate PDF report: $e');
    }
  }

({
  DateTime signalStart,
  DateTime signalEnd,
  List<int> timestamps,
  List<double> values,
}) prepareSpO2(
  List<({DateTime time, double value})> samples,
) {
  final sorted = [...samples]..sort((a, b) => a.time.compareTo(b.time));

  final signalStart = DateTime(
    sorted.first.time.year,
    sorted.first.time.month,
    sorted.first.time.day,
    sorted.first.time.hour,
    sorted.first.time.minute,
    sorted.first.time.second,
  );

  final last = sorted.last.time;
  final signalEnd = DateTime(
    last.year,
    last.month,
    last.day,
    last.hour,
    last.minute,
    last.second,
  );

  final totalSeconds = signalEnd.difference(signalStart).inSeconds + 1;

  final outT = List<int>.generate(totalSeconds, (i) => i);

  final outV = List<double>.filled(totalSeconds, 0.0);

  for (final sample in sorted) {
    final idx = sample.time.difference(signalStart).inSeconds;

    if (idx >= 0 && idx < totalSeconds) {
      outV[idx] = sample.value;
    }
  }

  return (
    signalStart: signalStart,
    signalEnd: signalEnd,
    timestamps: outT,
    values: outV,
  );
}

  List<int> buildSleepStageVectorFromAwakePoints({
    required List<HealthDataPoint> sleepPoints,
    required DateTime signalStart,
    required int length,
  }) {
    final stages = List<int>.filled(length, 1); // default asleep

    for (final point in sleepPoints) {
      if (point.type != HealthDataType.SLEEP_AWAKE) continue;

      final startIndex = point.dateFrom.difference(signalStart).inSeconds;
      final endIndex = point.dateTo.difference(signalStart).inSeconds;

      final safeStart = max(0, startIndex);
      final safeEnd = min(length, endIndex);

      for (int i = safeStart; i < safeEnd; i++) {
        stages[i] = 0;
      }
    }

    return stages;
  }
}