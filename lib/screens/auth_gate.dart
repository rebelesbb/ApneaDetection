import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:apnea_detector/screens/complete_profile_screen.dart';
import 'package:apnea_detector/screens/login_screen.dart';
import 'package:apnea_detector/screens/main_screen.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  final AuthController authController;

  const AuthGate({
    super.key,
    required this.authController,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    widget.authController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final state = widget.authController.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!state.isAuthenticated) {
          return LoginScreen(authController: widget.authController);
        }

        if (state.shouldCompleteProfile) {
          return CompleteProfileScreen(authController: widget.authController);
        }

        return const MainScreen();
      },
    );
  }
}