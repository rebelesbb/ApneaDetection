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

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.tealAccent.shade400,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.tealAccent.shade400.withAlpha(200),
                          Colors.tealAccent.shade400.withAlpha(0),
                        ],
                      )
                    )
                  )
                ],
                extraLinesData: ExtraLinesData(
                  verticalLines: record.predictions.asMap().entries
                  .where((e) => e.value == 1)
                  .map((e) => VerticalLine(
                    x: (e.key * 60).toDouble(),
                    color: Colors.pink.shade900.withAlpha(100),
                    strokeWidth: 4
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
              _buildLegendItem("SpO2 Level", Colors.tealAccent.shade400),
              _buildLegendItem("Apnea Event", Colors.pink.shade900.withAlpha(100)),
            ],
          ),
        )
      ]
    );
  }
}