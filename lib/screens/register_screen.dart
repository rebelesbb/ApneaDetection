import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:apnea_detector/screens/terms_and_conditions_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;

  const RegisterScreen({
    super.key,
    required this.authController,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    setState(() {
      _localError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (username.length < 3) {
      setState(() => _localError = 'Username must have at least 3 characters.');
      return;
    }

    if (password.length < 6) {
      setState(() => _localError = 'Password must have at least 6 characters.');
      return;
    }

    if (password != repeatPassword) {
      setState(() => _localError = 'Passwords do not match.');
      return;
    }

    if (!_acceptedTerms) {
      setState(() => _localError = 'You must accept the terms and conditions.');
      return;
    }

    final success = await widget.authController.registerAndLogin(
      username: username,
      password: password,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
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
                      constraints: const BoxConstraints(maxWidth: 420),
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
                              const SizedBox(height: 8),
                              const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Register to save your data and continue across sessions.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _repeatPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Repeat password',
                                  filled: true,
                                  fillColor: Colors.white.withAlpha(10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                },
                                title: const Text('I agree to the terms and conditions'),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TermsAndConditionsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Read terms and conditions'),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                  onPressed: state.isLoading ? null : _onRegister,
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Create account'),
                                ),
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
}