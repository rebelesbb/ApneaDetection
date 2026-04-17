import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/screens/history_screen.dart';
import 'package:apnea_detector/screens/insights_screen.dart';
import 'package:apnea_detector/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import "package:apnea_detector/screens/home_screen.dart";

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen>createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final HomeController controller = DI.I.sleepController;

  @override
  void initState() {
    super.initState();
    controller.load();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestHealthPermissionsAtStartup();
    });
  }

  Future<void> _requestHealthPermissionsAtStartup() async {
    await DI.I.healthService.requestPermissions();
  }

  final pages = [
    const HomeScreen(),
    const HistoryScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color.fromARGB(255, 52, 36, 62),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "History",
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: "Insights",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_outlined),
            selectedIcon: Icon(Icons.person_2),
            label: "Profile",
          )
        ]
      )
    );
  }
}
