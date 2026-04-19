enum ChartMode {
  none,
  last3Days,
  last7Days,
  all,
}

extension ChartModeApiValue on ChartMode {
  String toApiValue() {
    switch (this) {
      case ChartMode.none:
        return 'none';
      case ChartMode.last3Days:
        return 'last_3_days';
      case ChartMode.last7Days:
        return 'last_7_days';
      case ChartMode.all:
        return 'all';
    }
  }

  String get label {
    switch (this) {
      case ChartMode.none:
        return 'No detailed charts';
      case ChartMode.last3Days:
        return 'Detailed charts for last 3 days';
      case ChartMode.last7Days:
        return 'Detailed charts for last 7 days';
      case ChartMode.all:
        return 'Detailed charts for all sessions';
    }
  }
}

class SleepReportRequest {
  final DateTime startDate;
  final DateTime endDate;
  final ChartMode chartMode;

  const SleepReportRequest({
    required this.startDate,
    required this.endDate,
    required this.chartMode,
  });

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'chart_mode': chartMode.toApiValue(),
      };
}