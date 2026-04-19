import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/screens/auth_gate.dart';
//import 'package:apnea_detector/screens/test_screen.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DI.I.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apnea Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 0, 255),
          brightness: Brightness.dark
          ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.pinkAccent.shade700.withAlpha(200),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: Colors.blueGrey.shade100);
              }
              return IconThemeData(color: Colors.blueGrey.shade200);
            }),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(color: Colors.pinkAccent.shade100);
              }
              return TextStyle(color: Colors.blueGrey.shade200);
            }),
          ),
      ),
      home: AuthGate(authController: DI.I.authController),
      //home: TestScreen(),
    );
  }
}
