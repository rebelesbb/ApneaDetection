import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/components/glass_button.dart';
import 'package:apnea_detector/components/info_card.dart';
import 'package:apnea_detector/components/metric_card.dart';
import 'package:apnea_detector/components/results_chart.dart';
import 'package:apnea_detector/components/sleep_target_card.dart';
import 'package:apnea_detector/components/sleep_window_card.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/core/constants/home_text.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/models/spo2_session_record.dart';
import 'package:apnea_detector/screens/analyze_sleep_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController homeController;
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    homeController = DI.I.sleepController;
    homeController.loadTodaySession();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(alignment: Alignment.topLeft),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:AnimatedBuilder(
            animation: homeController,
            builder: (_, _) {
              final state = homeController.state;

              if(state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if(state.todaySession == null) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnalyzeSleepScreen(controller: homeController)
                          ),
                        );
                      
                      if(result == true) {
                        homeController.loadTodaySession();
                      }
                    }, 
                    child: const Text("Analyze last night sleep"),
                  ),
                );
              }

              // Main content when data is available

              final record = state.todaySession!;
              final ahi = record.ahi;
              final ahiLevel = _ahiLevelText(ahi);
              final ahiColor = _ahiLevelColor(ahi);

              final sleepStart = record.startTime;
              final sleepEnd = record.endTime;
              final sleepDuration = _extractSleepDuration(record);

              final user = DI.I.authController.state.currentUser;
              final targetSleepDuration = user != null && user.sleepTarget != null
                ? Duration(hours: user.sleepTarget!)
                : const Duration(hours: 8);

              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 64),
                    InfoCard(
                      title: "What is AHI?", 
                      content: HomeText.ahiExplanation, 
                      icon: Icons.air
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: "AHI",
                              value: ahi.toStringAsFixed(1),
                              subtitle: "estimated events/hour",
                              icon: Icons.monitor_heart_outlined,
                              color: Colors.cyanAccent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: "Severity",
                              value: ahiLevel,
                              subtitle: _ahiLevelSubtitle(ahi),
                              icon: Icons.warning_amber_rounded,
                              color: ahiColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GlassButton(
                        label: _showChart ? "Hide sleep chart" : "Show sleep chart",
                        icon: _showChart ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        onPressed: () {
                          setState(() {
                            _showChart = !_showChart;
                          });
                        },
                      ),

                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 500),
                        crossFadeState: _showChart
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                        firstChild: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            color: Colors.white.withAlpha(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ResultsChart(record: record),
                              ),
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      InfoCard(
                        title: "Healthy sleep",
                        icon: Icons.nightlight_round,
                        color: Colors.lightBlueAccent,
                        content: HomeText.healthySleep,
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SleepWindowCard(
                              start: sleepStart,
                              end: sleepEnd,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SleepTargetCard(
                              sleepDuration: sleepDuration,
                              targetDuration: targetSleepDuration,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Card(
                      color: Colors.white.withAlpha(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text(
                                "Heavily smoked yesterday",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              value: record.hasSmoked,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.cyanAccent,
                              checkColor: Colors.black,
                              onChanged: (bool? value) async {
                                if (value == null) return;

                                final updated = record.copyWith(hasSmoked: value);
                                await homeController.updateRecord(updated);
                              },
                            ),
                            CheckboxListTile(
                              title: const Text(
                                "Drank alcohol yesterday",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              value: record.hasDrunkAlcohol,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.cyanAccent,
                              checkColor: Colors.black,
                              onChanged: (bool? value) async {
                                if (value == null) return;

                                final updated = record.copyWith(hasDrunkAlcohol: value);
                                await homeController.updateRecord(updated);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                      const SizedBox(height: 16),

                      InfoCard(
                        title: "Smoking",
                        icon: Icons.smoke_free,
                        color: Colors.orangeAccent,
                        content: HomeText.smokingInfo
                      ),

                      const SizedBox(height: 12),

                      InfoCard(
                        title: "Alcohol",
                        icon: Icons.local_bar_outlined,
                        color: Colors.pinkAccent,
                        content: HomeText.alcoholInfo,
                      ),

                      const SizedBox(height: 24),
                  ],
                )
              );
            }
          )
          ),
        
      ]
    );
  }

  Duration _extractSleepDuration(Spo2SessionRecord record) {
    final start = record.startTime;
    final end = record.endTime;

    return end.difference(start);
  }

  String _ahiLevelText(double ahi) {
    if (ahi < 5) return "Normal";
    if (ahi < 15) return "Mild";
    if (ahi < 30) return "Moderate";
    return "Severe";
  }

  String _ahiLevelSubtitle(double ahi) {
    if (ahi < 5) return "under 5";
    if (ahi < 15) return "5 to 15";
    if (ahi < 30) return "15 to 30";
    return "30+";
  }

  Color _ahiLevelColor(double ahi) {
    if (ahi < 5) return Colors.greenAccent;
    if (ahi < 15) return Colors.yellowAccent;
    if (ahi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}