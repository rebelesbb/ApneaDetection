import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/components/results_chart.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/screens/analyze_sleep_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController(sleepRepository: DI.I.sleepRepository)..load();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(alignment: Alignment.topLeft),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final state = controller.state;

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
                          builder: (_) => AnalyzeSleepScreen(homeController: controller)
                          ),
                        );
                      
                      if(result == true) {
                        controller.load();
                      }
                    }, 
                    child: const Text("Analyze last night sleep"),
                  ),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      ResultsChart(record: state.todaySession!)
                    ],
                  )
                );
            }
          )
          ),
        
      ]
    );
  }
}