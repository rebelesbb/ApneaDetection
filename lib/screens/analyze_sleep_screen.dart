import 'package:apnea_detector/utils/background_gradient.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/utils/error_message.dart';
import 'package:flutter/material.dart';

class AnalyzeSleepScreen extends StatefulWidget {
  final HomeController homeController;
  const AnalyzeSleepScreen({
    super.key,
    required this.homeController,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnalyzeSleepScreenState();
  }
}

class _AnalyzeSleepScreenState extends State<AnalyzeSleepScreen> {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _error;

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context, 
      initialDate: yesterday,
      firstDate: yesterday,
      lastDate: today,
      );

    if(picked != null) setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
    );
    if(picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if(picked != null) setState(() => _endTime = picked);
  }

  DateTime _compose(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _run() async {
    setState(() => _error = null);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if(_startDate == null || _startTime == null || _endTime == null) {
      setState(() => _error = "Please fill all fields");
      showErrorAlert(context, _error.toString());
      return;
    }

    final startDateTime = _compose(_startDate!, _startTime!);
    final endDateTime = _compose(today, _endTime!);

    if(endDateTime.isBefore(startDateTime)) {
      setState(() => _error = "End time must be after start time");
      showErrorAlert(context, _error.toString());
      return;
    }

    final ok = await widget.homeController.runAnalyze(startDateTime, endDateTime);
    if(!mounted) return;

    if(ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = widget.homeController.state.errorMessage ?? "An error occurred");
      showErrorAlert(context, _error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(alignment: Alignment.bottomRight),
        Scaffold(
          backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    title: Text(_startDate?.toString().split(' ').first ?? "Select start date"),
                    trailing: const Icon(Icons.date_range), onTap: _pickStartDate),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(_startTime?.format(context) ?? "Select start time"),
                    trailing: const Icon(Icons.access_time), onTap: _pickStartTime),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(_endTime?.format(context) ?? "Select end time"),
                    trailing: const Icon(Icons.access_time), onTap: _pickEndTime),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _run, child: const Text("Run analysis"))
                  ),
                ],
              ),
            )
        )
      ],
    );
  }
}