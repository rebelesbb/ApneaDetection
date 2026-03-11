import 'package:apnea_detector/models/spo2_session_record.dart';

class SleepAnalyticsCalculator {
  static double calculateCorrelationScore({
    required List<Spo2SessionRecord> sessions, 
    required bool Function(Spo2SessionRecord) condition
    }) {

    if (sessions.isEmpty) return 0.0;

    final withCondition = sessions.where(condition).toList();
    final withoutCondition = sessions.where((s) => !condition(s)).toList();

    if(withCondition.isEmpty || withoutCondition.isEmpty) return 0.0;

    double avgWith = withCondition.map((session) => session.ahi).reduce((a, b) => a + b) / withCondition.length;
    double avgWithout = withoutCondition.map((session) => session.ahi).reduce((a, b) => a + b) / withoutCondition.length;

    if(avgWithout == 0) return 0.0;

    return ((avgWith - avgWithout) / avgWithout) * 100;
  }
}