class Spo2PredictRequest {
  final List<double> values;
  final List<int> timestamps;

  Spo2PredictRequest({
    required this.values,
    required this.timestamps,
  });

  Map<String, dynamic> toJson() => {
        'values': values,
        'timestamps': timestamps,
      };
}

class Spo2PredictResponse {
  final double ahi;
  final List<int> predictions;

  Spo2PredictResponse({
    required this.ahi,
    required this.predictions,
  });

  factory Spo2PredictResponse.fromJson(Map<String, dynamic> json) {
    return Spo2PredictResponse(
      ahi: json['ahi'],
      predictions: List<int>.from(json['predictions']),
    );
  }
}