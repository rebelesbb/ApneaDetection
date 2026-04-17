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

  final startTime = DateTime(2026, 3, 30, 21, 5, 46, 0, 0);
  final endTime = DateTime(2026, 3, 31, 7, 11, 2, 0, 0);

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
      final rawData = await rootBundle.loadString('assets/test_spo2_osa22.csv');

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
          ],
        ),
      ),
    );
  }
}

