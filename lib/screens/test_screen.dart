import 'package:apnea_detector/services/health_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:csv/csv.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final HealthService _healthService = HealthService();

  final startTime = DateTime(2026, 5, 12, 21, 34, 01, 0, 0);
  final endTime = DateTime(2026, 5, 13, 5, 58, 38, 0, 0);

  void _testFetchData() async {
    bool hasPermission = await _healthService.requestPermissions();
    
    if (!hasPermission) {
      print("Error: Permission denied by user");
      return; 
    }

    List<HealthDataPoint> data = await _healthService.fetchSpO2(startTime, endTime);

    print('Fetched ${data.length} data points:');
    final firstThirty = data.length > 30 ? data.take(30) : data;
    final lastThirty = data.length > 30 ? data.skip(data.length - 30) : data;
    print('First 30 data points:');
    for (var point in firstThirty) {
      print('Value: ${point.value}, Date: ${point.dateFrom}, Type: ${point.type}');
    }
    print('Last 30 data points:');
    for (var point in lastThirty) {
      print('Value: ${point.value}, Date: ${point.dateFrom}, Type: ${point.type}');
    }
  }

  void _writeCsvDataToHealthConnect() async {
    bool hasPermission = await _healthService.requestPermissions();
    
    if (!hasPermission) {
      print("Error: Permission denied by user");
      return; 
    }
    try{
      final rawData = await rootBundle.loadString('assets/06_OSA_test.csv');

      List<List<dynamic>> csvTable = csv.decode(rawData);
      List<({DateTime time, double value})> samples = [];

      for (int i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];
        if (row.isEmpty || row.length < 2) continue;

        String timeString = row[0].toString().trim(); 

        if(row[1] == null || row[1].toString().trim().isEmpty || row[1].toString().trim() == "-") continue;
        double spo2Value = double.parse(row[1].toString()); 

        List<String> timeParts = timeString.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        double secAndMs = double.parse(timeParts[2]);
        int second = secAndMs.floor();

        DateTime targetDate = hour < startTime.hour ? endTime : startTime;

        DateTime fullDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          hour,
          minute,
          second,
        );

        samples.add((time: fullDateTime, value: spo2Value));
      }

      final inserted = await _healthService.writeSpO2(samples);
      print("Finished writing data. Successfully wrote $inserted records to Health Connect.");
    } catch (e) {
      print("Error while trying to write data: $e");
    }
  }

  void _writeCsvSleepToHealthConnect() async {
    bool hasPermission = await _healthService.requestPermissions();

    if (!hasPermission) {
      print("Error: Permission denied by user");
      return;
    }

    try {
      final rawData = await rootBundle.loadString('assets/06_OSA_test.csv');

      List<List<dynamic>> csvTable = csv.decode(rawData);
      List<({DateTime time, String stage})> rawStages = [];

      for (int i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];

        // CSV: time,spo2,stage
        if (row.isEmpty || row.length < 3) continue;

        String timeString = row[0].toString().trim();
        String stageString = row[2].toString().trim();

        if (stageString.isEmpty || stageString == "-") continue;

        List<String> timeParts = timeString.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        double secAndMs = double.parse(timeParts[2]);
        int second = secAndMs.floor();

        DateTime targetDate = hour < startTime.hour ? endTime : startTime;

        DateTime fullDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          hour,
          minute,
          second,
        );

        rawStages.add((time: fullDateTime, stage: stageString));
      }

      if (rawStages.length < 2) {
        print("Not enough sleep stage rows.");
        return;
      }

      List<({DateTime start, DateTime end, String stage})> stageIntervals = [];

      for (int i = 0; i < rawStages.length - 1; i++) {
        final current = rawStages[i];
        final next = rawStages[i + 1];

        if (!next.time.isAfter(current.time)) continue;

        stageIntervals.add((
          start: current.time,
          end: next.time,
          stage: current.stage,
        ));
      }

      final inserted = await _healthService.writeSleepSession(
        startTime: startTime,
        endTime: endTime,
        stages: stageIntervals,
      );

      print(
        "Finished writing sleep session. Inserted $inserted session with ${stageIntervals.length} intervals.",
      );
    } catch (e) {
      print("Error while trying to write sleep data: $e");
    }
  }

  void _testFetchSleepData() async {
    bool hasPermission = await _healthService.requestPermissions();

    if (!hasPermission) {
      print("Error: Permission denied by user");
      return;
    }

    List<HealthDataPoint> data =
        await _healthService.fetchSleep(startTime, endTime);

    data.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    print('Fetched ${data.length} sleep data points:');

    final firstThirty = data.length > 30 ? data.take(30) : data;
    final lastThirty = data.length > 30 ? data.skip(data.length - 30) : data;
    print('First 30 data points:');
    for (var point in firstThirty) {
      print('Value: ${point.value}, Date: ${point.dateFrom}, Type: ${point.type}');
    }
    print('Last 30 data points:');
    for (var point in lastThirty) {
      print('Value: ${point.value}, Date: ${point.dateFrom}, Type: ${point.type}');
    }

    int awakeCount = 0;
    int asleepCount = 0;

    for (var point in data) {
      if (point.type == HealthDataType.SLEEP_AWAKE) {
        awakeCount++;
      } else if (point.type == HealthDataType.SLEEP_LIGHT) {
        asleepCount++;
      }
    }

    print("AWAKE points: $awakeCount");
    print("ASLEEP points: $asleepCount");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _writeCsvDataToHealthConnect,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Write data to Health Connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFetchData, 
              child: const Text('Read data from Health Connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _writeCsvSleepToHealthConnect,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Write sleep to Health Connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testFetchSleepData,
              child: const Text('Read sleep from Health Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

