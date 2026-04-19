import 'dart:convert';

class Spo2SessionRecord {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<double> values;
  final List<int> timestamps;
  final double ahi;
  final List<int> predictions;
  final bool hasSmoked;
  final bool hasDrunkAlcohol;

  Spo2SessionRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.values,
    required this.timestamps,
    required this.ahi,
    required this.predictions,
    required this.hasSmoked,
    required this.hasDrunkAlcohol,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'values': values,
        'timestamps': timestamps,
        'ahi': ahi,
        'predictions': predictions,
        'hasSmoked': hasSmoked,
        'hasDrunkAlcohol': hasDrunkAlcohol,
      };

  Spo2SessionRecord copyWith({bool? hasSmoked, bool? hasDrunkAlcohol}) {
    return Spo2SessionRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      values: values,
      timestamps: timestamps,
      ahi: ahi,
      predictions: predictions,
      hasSmoked: hasSmoked ?? this.hasSmoked,
      hasDrunkAlcohol: hasDrunkAlcohol ?? this.hasDrunkAlcohol
    );
  }

  factory Spo2SessionRecord.fromJson(Map<String, dynamic> json) {
    return Spo2SessionRecord(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      values: List<double>.from(json['values']),
      timestamps: List<int>.from(json['timestamps']),
      ahi: json['ahi'],
      predictions: List<int>.from(json['predictions']),
      hasSmoked: json['has_smoked'] ?? false,
      hasDrunkAlcohol: json['has_drunk_alcohol'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static Spo2SessionRecord fromJsonString(String jsonString) =>
      Spo2SessionRecord.fromJson(jsonDecode(jsonString));
}