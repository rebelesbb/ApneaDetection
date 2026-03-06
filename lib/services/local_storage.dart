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
}