import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/components/info_card.dart';
import 'package:apnea_detector/controllers/insights_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:apnea_detector/core/constants/insights_text.dart';
import 'dart:math' as math;

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final InsightsController controller;

  @override
  void initState() {
    super.initState();
    controller = DI.I.insightsController;
    controller.loadWeek(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final weekSessions = state.sessions;

        return Stack(
          children: [
            const BackgroundGradient(alignment: Alignment.topLeft),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    _buildWeekSelector(controller),
                    const SizedBox(height: 24),
                    _buildAHIChart(weekSessions, state.selectedWeekStart),
                    const SizedBox(height: 24),
                    _buildWeeklySeverityInfoCard(weekSessions),
                    const SizedBox(height: 32),
                    InfoCard(
                      title: InsightsText.nicotineTitle,
                      icon: Icons.smoke_free,
                      color: Colors.orangeAccent,
                      content: InsightsText.nicotineInfo,
                    ),
                    _buildCorrelationStat(
                      label: "Smoking Correlation",
                      score: state.smokingCorrelation,
                      days: state.smokingDaysCount,
                    ),
                    const SizedBox(height: 20),
                    InfoCard(
                      title: InsightsText.alcoholTitle,
                      icon: Icons.local_bar,
                      color: Colors.redAccent,
                      content: InsightsText.alcoholInfo,
                    ),
                    _buildCorrelationStat(
                      label: "Alcohol Correlation",
                      score: state.alcoholCorrelation,
                      days: state.alcoholDaysCount,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekSelector(InsightsController controller) {
    final start = controller.state.selectedWeekStart;
    final end = start.add(const Duration(days: 6));
    final rangeText =
        "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => controller.changeWeek(-1),
          icon: const Icon(Icons.chevron_left, color: Colors.cyanAccent),
        ),
        Text(
          rangeText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => controller.changeWeek(1),
          icon: const Icon(Icons.chevron_right, color: Colors.cyanAccent),
        ),
      ],
    );
  }

  Widget _buildAHIChart(List<Spo2SessionRecord> sessions, DateTime weekStart) {
    final maxAhi = sessions.isEmpty
    ? 0.0
    : sessions.map((s) => s.ahi).fold<double>(0.0, math.max);

    final chartMaxY = math.max(35.0, ((maxAhi + 5) / 5).ceil() * 5.0);

    return AspectRatio(
      aspectRatio: 1.2,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "AHI: ${rod.toY.toStringAsFixed(1)}",
                  const TextStyle(color: Colors.cyanAccent),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value % 5 != 0) return const SizedBox.shrink();

                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final day = weekStart.add(Duration(days: index));
            final session = sessions.cast<Spo2SessionRecord?>().firstWhere(
              (s) => s != null && isSameDay(s.endTime, day),
              orElse: () => null,
            );

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: session?.ahi ?? 0,
                  color: session == null
                      ? Colors.white10
                      : (session.ahi < 5
                          ? Colors.cyanAccent
                          : session.ahi < 15
                              ? Colors.amberAccent
                              : session.ahi < 30
                                  ? Colors.deepOrangeAccent
                                  : Colors.redAccent),
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCorrelationStat({
    required String label,
    required double score,
    required int days,
  }) {
    final isNegative = score > 5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(
                "$days days recorded",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          Text(
            score == 0 ? "No data" : "${score > 0 ? '+' : ''}${score.toStringAsFixed(1)}%",
            style: TextStyle(
              color: isNegative ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySeverityInfoCard(List<Spo2SessionRecord> sessions) {
    final recordedDays = sessions.length;

    if (recordedDays == 0) {
      return const InfoCard(
        title: InsightsText.noDataTitle,
        icon: Icons.info_outline,
        color: Colors.cyanAccent,
        content: InsightsText.noDataContent,
      );
    }

    final severeDays = sessions.where((s) => s.ahi >= 30).length;
    final moderateDays = sessions.where((s) => s.ahi >= 15 && s.ahi < 30).length;
    final mildDays = sessions.where((s) => s.ahi >= 5 && s.ahi < 15).length;

    if (severeDays >= 2) {
      return InfoCard(
        title: InsightsText.severeFrequentTitle(),
        icon: Icons.warning_amber_rounded,
        color: Colors.redAccent,
        content: InsightsText.severeFrequentContent(severeDays),
      );
    }

    if (severeDays == 1) {
      return const InfoCard(
        title: InsightsText.severeSingleTitle,
        icon: Icons.warning_amber_rounded,
        color: Colors.redAccent,
        content: InsightsText.severeSingleContent,
      );
    }

    if (moderateDays >= 3) {
      return InfoCard(
        title: InsightsText.moderateRepeatedTitle(),
        icon: Icons.trending_up_rounded,
        color: Colors.deepOrangeAccent,
        content: InsightsText.moderateRepeatedContent(moderateDays),
      );
    }

    if (moderateDays > 0) {
      return InfoCard(
        title: InsightsText.moderateDetectedTitle,
        icon: Icons.info_outline_rounded,
        color: Colors.orangeAccent,
        content: InsightsText.moderateDetectedContent(moderateDays),
      );
    }

    if (mildDays >= 3) {
      return InfoCard(
        title: InsightsText.mildPatternTitle,
        icon: Icons.nightlight_round,
        color: Colors.amberAccent,
        content: InsightsText.mildPatternContent(mildDays),
      );
    }

    if (mildDays > 0) {
      return const InfoCard(
        title: InsightsText.mildDetectedTitle,
        icon: Icons.nightlight_round,
        color: Colors.amberAccent,
        content: InsightsText.mildDetectedContent,
      );
    }

    return InfoCard(
      title: InsightsText.normalWeekTitle,
      icon: Icons.check_circle_outline_rounded,
      color: Colors.greenAccent,
      content: InsightsText.normalWeekContent(recordedDays),
    );
  }
}