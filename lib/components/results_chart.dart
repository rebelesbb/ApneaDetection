import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultsChart extends StatelessWidget {
  final Spo2SessionRecord record;

  const ResultsChart({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 10, bottom: 10),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            minY: 70,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: record.values.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value);
                }).toList(),
                isCurved: true,
                color: Colors.cyanAccent,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.cyanAccent.withAlpha(200),
                      Colors.cyanAccent.withAlpha(0),
                    ],
                  )
                )
              )
            ],
            extraLinesData: ExtraLinesData(
              verticalLines: record.predictions.asMap().entries
              .where((e) => e.value == 1)
              .map((e) => VerticalLine(
                x: e.key.toDouble(),
                color: Colors.redAccent.withAlpha(100),
                strokeWidth: 4
              )).toList()
            )
          )
        )
      ),
    );
  }
}