import 'dart:typed_data';
import 'package:apnea_detector/models/report_models.dart';
import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/sleep_api_models.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/services/local/auth_storage.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/sleep_api_service.dart';
import 'package:health/health.dart';

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

      final resampled = resampleTo1Hz(samples, startTime, endTime);
      if (resampled.values.length < 60) {
        return const Err(
            "Not enough data points, at least 1 minute of data is required");
      }

      final session = await sleepApiService.analyzeSession(
        accessToken: token,
        request: AnalyzeSpo2SessionRequest(
          startTime: startTime,
          endTime: endTime,
          values: resampled.values,
          timestamps: resampled.timestamps,
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

  ({List<int> timestamps, List<double> values}) resampleTo1Hz(
    List<({DateTime time, double value})> samples,
    DateTime start,
    DateTime end,
  ) {
    final totalSeconds = end.difference(start).inSeconds;
    final outT = <int>[];
    final outV = <double>[];

    int si = 0;
    double last = samples.first.value;

    for (int sec = 0; sec < totalSeconds; sec++) {
      final t = start.add(Duration(seconds: sec));

      while (si < samples.length && !samples[si].time.isAfter(t)) {
        last = samples[si].value;
        si++;
      }

      outT.add(sec);
      outV.add(last);
    }

    return (timestamps: outT, values: outV);
  }
}