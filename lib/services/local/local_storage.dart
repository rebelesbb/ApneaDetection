import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const _boxName = "spo2_sessions";

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> saveSession(Spo2SessionRecord record) async {
    await _box.put(record.id, record.toJsonString());
  }

  List<Spo2SessionRecord> getAllSessions() {
    return _box.values
        .map((s) => Spo2SessionRecord.fromJsonString(s))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  Spo2SessionRecord? getTodaySession() {
    final now = DateTime.now();
    final todaySessions = getAllSessions().where((s) =>
        s.startTime.year == now.year &&
        s.startTime.month == now.month &&
        (s.startTime.day == now.day || s.startTime.day == now.day - 1) &&
        s.endTime.day == now.day);
    return todaySessions.isNotEmpty ? todaySessions.first : null;
  }
}