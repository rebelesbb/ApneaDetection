import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultsChart extends StatelessWidget {
  final Spo2SessionRecord record;

  const ResultsChart({
    super.key,
    required this.record,
  });

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> _buildSpo2Bars() {
    final bars = <LineChartBarData>[];
    final current = <FlSpot>[];

    void flushCurrent() {
      if (current.length >= 2) {
        bars.add(
          LineChartBarData(
            spots: List<FlSpot>.from(current),
            isCurved: false,
            color: Colors.cyanAccent,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.cyanAccent.withAlpha(120),
                  Colors.cyanAccent.withAlpha(0),
                ],
              ),
            ),
          ),
        );
      }

      current.clear();
    }

    for (int i = 0; i < record.spo2values.length; i++) {
      final value = record.spo2values[i];

      final isValid = value >= 60 && value <= 100;

      if (!isValid) {
        flushCurrent();
        continue;
      }

      current.add(
        FlSpot(
          i.toDouble(),
          value.clamp(70.0, 100.0).toDouble(),
        ),
      );
    }

    flushCurrent();

    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final xMax = record.spo2values.isEmpty
      ? 0.0
      : (record.spo2values.length - 1).toDouble();

  final durationSeconds = record.endTime
      .difference(record.startTime)
      .inSeconds
      .abs();

  final bottomInterval = durationSeconds > 6 * 3600
      ? 7200.0 
      : 3600.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          "Estimated AHI: ${record.ahi.toStringAsFixed(2)}",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          record.ahi < 5 ? "Normal" : record.ahi < 15 ? "Mild" : record.ahi < 30 ? "Moderate" : "Severe",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 6, top: 10, bottom: 10),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                clipData: FlClipData.all(),
                minX: 0,
                maxX: xMax,
                minY: 70,
                maxY: 100,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: bottomInterval,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > xMax) {
                          return const SizedBox.shrink();
                        }

                        final isAutoEndLabel = value > 0 && (xMax - value).abs() < 5;
                        if (isAutoEndLabel) {
                          return const SizedBox.shrink();
                        }

                        final time = record.startTime.add(
                          Duration(seconds: value.round()),
                        );

                        final label =
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if(value % 5 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize:  10, color: Colors.white70)
                            );
                        }
                        return SizedBox();
                      },  
                    )
                  )
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: _buildSpo2Bars(),
                extraLinesData: ExtraLinesData(
                  verticalLines: record.predictions.asMap().entries
                  .where((e) => e.value == 1)
                  .map((e) => VerticalLine(
                    x: (e.key).toDouble(),
                    color: Colors.pink.shade900.withAlpha(100),
                    strokeWidth: 2
                  )).toList()
                )
              )
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem("SpO2 Level", Colors.cyanAccent),
              _buildLegendItem("Detected Apnea Event", Colors.pink.shade900.withAlpha(100)),
            ],
          ),
        )
      ]
    );
  }
}