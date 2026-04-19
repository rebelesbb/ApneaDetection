import 'package:apnea_detector/models/spo2_session_record.dart';

class AnalyzeSpo2SessionRequest {
  final DateTime startTime;
  final DateTime endTime;
  final List<double> values;
  final List<int> timestamps;
  final bool hasSmoked;
  final bool hasDrunkAlcohol;

  const AnalyzeSpo2SessionRequest({
    required this.startTime,
    required this.endTime,
    required this.values,
    required this.timestamps,
    this.hasSmoked = false,
    this.hasDrunkAlcohol = false,
  });

  Map<String, dynamic> toJson() => {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'values': values,
        'timestamps': timestamps,
        'has_smoked': hasSmoked,
        'has_drunk_alcohol': hasDrunkAlcohol,
      };
}

class UpdateSessionFlagsRequest {
  final bool hasSmoked;
  final bool hasDrunkAlcohol;

  const UpdateSessionFlagsRequest({
    required this.hasSmoked,
    required this.hasDrunkAlcohol,
  });

  Map<String, dynamic> toJson() => {
        'has_smoked': hasSmoked,
        'has_drunk_alcohol': hasDrunkAlcohol,
      };
}

class WeeklyInsightsResponse {
  final DateTime startDate;
  final DateTime endDate;
  final List<Spo2SessionRecord> sessions;
  final double smokingCorrelation;
  final double alcoholCorrelation;
  final int smokingDaysCount;
  final int alcoholDaysCount;

  const WeeklyInsightsResponse({
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.smokingCorrelation,
    required this.alcoholCorrelation,
    required this.smokingDaysCount,
    required this.alcoholDaysCount,
  });

  factory WeeklyInsightsResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsResponse(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      sessions: (json['sessions'] as List)
          .map((e) => Spo2SessionRecord.fromJson(e))
          .toList(),
      smokingCorrelation: (json['smoking_correlation'] as num).toDouble(),
      alcoholCorrelation: (json['alcohol_correlation'] as num).toDouble(),
      smokingDaysCount: json['smoking_days_count'],
      alcoholDaysCount: json['alcohol_days_count'],
    );
  }
}