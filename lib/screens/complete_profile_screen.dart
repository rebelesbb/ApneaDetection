import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class CompleteProfileScreen extends StatefulWidget {
  final AuthController authController;

  const CompleteProfileScreen({
    super.key,
    required this.authController,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _sleepTargetController = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _sleepTargetController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  Future<void> _onSave() async {
    setState(() {
      _localError = null;
    });

    final height = _parseDouble(_heightController.text);
    final weight = _parseDouble(_weightController.text);
    final age = _parseInt(_ageController.text);
    final sleepTarget = _parseInt(_sleepTargetController.text);

    if (_heightController.text.trim().isNotEmpty && height == null) {
      setState(() => _localError = 'Height must be a valid number.');
      return;
    }

    if (_weightController.text.trim().isNotEmpty && weight == null) {
      setState(() => _localError = 'Weight must be a valid number.');
      return;
    }

    if (_ageController.text.trim().isNotEmpty && age == null) {
      setState(() => _localError = 'Age must be a valid integer.');
      return;
    }

    if (_sleepTargetController.text.trim().isNotEmpty && sleepTarget == null) {
      setState(() => _localError = 'Sleep target must be a valid integer.');
      return;
    }

    await widget.authController.saveProfile(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      height: height,
      weight: weight,
      age: age,
      sleepTarget: sleepTarget,
    );
  }

  void _skip() {
    widget.authController.skipProfileCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final state = widget.authController.state;

        return Stack(
          children: [
            const BackgroundGradient(alignment: Alignment.topLeft),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Card(
                        color: Colors.white.withAlpha(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: Colors.white.withAlpha(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Complete your profile',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can fill this in now or skip and complete it later.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _nameController,
                                decoration: _decoration('Name'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _decoration('Height'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _decoration('Weight'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: _decoration('Age'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _sleepTargetController,
                                keyboardType: TextInputType.number,
                                decoration: _decoration('Sleep target'),
                              ),
                              const SizedBox(height: 18),
                              if (_localError != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _localError!,
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              if (state.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed: state.isLoading ? null : _onSave,
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Save profile'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: _skip,
                                child: const Text('Skip for now'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withAlpha(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}