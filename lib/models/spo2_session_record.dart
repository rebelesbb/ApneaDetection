import 'dart:convert';

class Spo2SessionRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<double> values;
  final List<int> timestamps;
  final double ahi;
  final List<int> predictions;

  Spo2SessionRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.values,
    required this.timestamps,
    required this.ahi,
    required this.predictions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'values': values,
        'timestamps': timestamps,
        'ahi': ahi,
        'predictions': predictions,
      };

  factory Spo2SessionRecord.fromJson(Map<String, dynamic> json) {
    return Spo2SessionRecord(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      values: List<double>.from(json['values']),
      timestamps: List<int>.from(json['timestamps']),
      ahi: json['ahi'],
      predictions: List<int>.from(json['predictions']),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static Spo2SessionRecord fromJsonString(String jsonString) =>
      Spo2SessionRecord.fromJson(jsonDecode(jsonString));
}