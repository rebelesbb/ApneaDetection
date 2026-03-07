import 'package:apnea_detector/core/result.dart';
import 'package:apnea_detector/models/spo2_predict_models.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/services/api_services.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/local_storage.dart';
import 'package:health/health.dart';

class SleepRepository {
  final LocalStorageService localStorageService;
  final ApiService apiService;
  final HealthService healthService;

  SleepRepository({
    required this.localStorageService,
    required this.apiService,
    required this.healthService,
  });

  Spo2SessionRecord? getTodaySession() => null; //localStorageService.getTodaySession();

  Future<Result<Spo2SessionRecord>> analyzeSleep({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final ok = await healthService.requestPermissions();
      if(!ok) {
        return const Err("Health permissions denied");
      }

      final points = await healthService.fetchSpO2(startTime, endTime);
      if(points.isEmpty) {
        return const Err("No SpO2 data found for the given period");
      }

      final samples = points
      .map((p) => (time: p.dateFrom, value: (p.value as NumericHealthValue).numericValue.toDouble()))
      .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

      print('First 30 fetched samples:');
      for (var sample in samples.take(30)) {
        print('Value: ${sample.value}, Time: ${sample.time}');
      }

      final resampled = resampleTo1Hz(samples, startTime, endTime);
      if(resampled.values.length < 60) {
        return const Err("Not enough data points, at least 1 minute of data is required");
      }

      final req = Spo2PredictRequest(
        timestamps: resampled.timestamps,
        values: resampled.values
      );

      final resp = await apiService.predictApnea(req);

      final record = Spo2SessionRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: startTime,
        endTime: endTime,
        timestamps: resampled.timestamps,
        values: resampled.values, 
        ahi: resp.ahi,
        predictions: resp.predictions
      );

      await localStorageService.saveSession(record);
      return Ok(record);
    } catch (e) {
      return Err("Error during sleep analysis: $e");
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