import 'package:apnea_detector/components/background_gradient.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGradient(alignment: Alignment.topLeft),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Terms and Conditions'),
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.white.withAlpha(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    '''
These terms and conditions are provided for demonstration purposes.

1. The application offers informational support and is not a medical diagnosis tool.
2. The user is responsible for verifying any health-related concerns with a medical professional.
3. Data may be stored locally and/or on the server depending on enabled features.
4. By using the application, you agree to the processing of your data for app functionality.
''',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}