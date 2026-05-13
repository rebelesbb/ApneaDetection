import 'dart:math';

import 'package:flutter/services.dart';
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();
  static const MethodChannel _channel = MethodChannel('hc_bulk');

  final types = [HealthDataType.BLOOD_OXYGEN, HealthDataType.SLEEP_AWAKE];
  final permissions = [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];

  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization(types, permissions: permissions);
  }

  Future<List<HealthDataPoint>> fetchSpO2(DateTime startTime, DateTime endTime) async {
    try{
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN], 
        startTime: startTime, 
        endTime: endTime);

        healthData = _health.removeDuplicates(healthData);

        return healthData;
    } catch (e) {
      print("Caught exception in getHealthDataFromTypes: $e");
      return [];
    }
  }

  Future<int> writeSpO2(List<({DateTime time, double value})> samples, {int batchSize = 1000}) async {
    int totalInserted = 0;

    for(int i = 0; i < samples.length; i += batchSize) {
      final chunk = samples.sublist(i, min(i+ batchSize, samples.length));

      final payload = chunk.map((s) => {
        'timeMillis': s.time.millisecondsSinceEpoch,
        'value': s.value,
      })
      .toList();

      final inserted = await _channel.invokeMethod<int>(
        'insertOxygenSaturation',
        {'samples': payload}
      );
      totalInserted += inserted ?? 0;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return totalInserted;
  }

  Future<List<HealthDataPoint>> fetchSleep(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
        ],
        startTime: startTime,
        endTime: endTime,
      );

      healthData = _health.removeDuplicates(healthData);
      return healthData;
    } catch (e) {
      print("Caught exception in fetchSleep: $e");
      return [];
    }
  }

  Future<int> writeSleepSession({
    required DateTime startTime,
    required DateTime endTime,
    required List<({DateTime start, DateTime end, String stage})> stages,
  }) async {
    final payloadStages = stages
        .map((s) => {
              'startMillis': s.start.millisecondsSinceEpoch,
              'endMillis': s.end.millisecondsSinceEpoch,
              'stage': s.stage,
            })
        .toList();

    final inserted = await _channel.invokeMethod<int>(
      'insertSleepSession',
      {
        'startMillis': startTime.millisecondsSinceEpoch,
        'endMillis': endTime.millisecondsSinceEpoch,
        'stages': payloadStages,
      },
    );

    return inserted ?? 0;
  }
}