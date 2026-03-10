import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/components/results_chart.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryScreen extends StatefulWidget {

  const HistoryScreen({
    super.key,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HomeController controller;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    controller = HomeController(sleepRepository: DI.I.sleepRepository)..load();
  }

  List<Spo2SessionRecord> _getEventsForDay(DateTime day) {
    return controller.state.allSessions.where((record) {
      return isSameDay(record.startTime, day);
    }).toList();
  }

  void _showDetails(Spo2SessionRecord record) {
    print(record.toJson().keys);
    Spo2SessionRecord currentRecord = record;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  Text("Analysis for ${currentRecord.startTime.day}/${currentRecord.startTime.month}/${currentRecord.startTime.year}", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ResultsChart(record: record), 
                  const SizedBox(height: 20),
                  Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Havily Smoked That Day", style: TextStyle(color: Colors.white, fontSize: 14)),
                            value: currentRecord.hasSmoked,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.cyanAccent,
                            onChanged: (bool? value) async {  
                              final updated = currentRecord.copyWith(hasSmoked: value);
                              setState(() => currentRecord = updated); 
                              await controller.updateRecord(updated);
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text("Drunk Alcohol That Day", style: TextStyle(color: Colors.white, fontSize: 14)),
                            value: currentRecord.hasDrunkAlcohol,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.cyanAccent,
                            onChanged: (bool? value) async {
                              final updated  = currentRecord.copyWith(hasDrunkAlcohol: value);
                              setState(() => currentRecord = updated);
                              await controller.updateRecord(updated);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(alignment: Alignment.topLeft),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("History"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDate ?? DateTime.now(),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                  
                  final records = _getEventsForDay(selectedDay);
                  if (records.isNotEmpty) {
                    _showDetails(records.first);
                  }
                },
                
                calendarStyle: CalendarStyle(
                  markerDecoration:  BoxDecoration(color: Colors.cyan.shade600, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.cyan.shade600, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.cyan.shade600, shape: BoxShape.circle),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white54),
                  weekendStyle: TextStyle(color: Colors.white54),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 17),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.cyanAccent),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.cyanAccent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}