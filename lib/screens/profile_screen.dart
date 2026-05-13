import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController authController;
  bool _isEditing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;
  late final TextEditingController _sleepTargetController;

  @override
  void initState() {
    super.initState();
    authController = DI.I.authController;

    final user = authController.state.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _sleepTargetController =
        TextEditingController(text: user?.sleepTarget?.toString() ?? '');
  }

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

  Future<void> _save() async {
    final success = await authController.saveProfile(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      height: _parseDouble(_heightController.text),
      weight: _parseDouble(_weightController.text),
      age: _parseInt(_ageController.text),
      sleepTarget: _parseInt(_sleepTargetController.text),
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _loadFromState() {
    final user = authController.state.currentUser;
    _nameController.text = user?.name ?? '';
    _heightController.text = user?.height?.toString() ?? '';
    _weightController.text = user?.weight?.toString() ?? '';
    _ageController.text = user?.age?.toString() ?? '';
    _sleepTargetController.text = user?.sleepTarget?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final state = authController.state;
        final user = state.currentUser;

        return Stack(
          children: [
            const BackgroundGradient(alignment: Alignment.topLeft),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('Profile'),
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () {
                      if (_isEditing) {
                        _loadFromState();
                      }
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                  ),
                ],
              ),
              body: user == null
                  ? const Center(child: Text('No user loaded'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
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
                                'Your profile',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildField('Name', _nameController, editable: _isEditing),
                              const SizedBox(height: 12),
                              _buildField(
                                'Height',
                                _heightController,
                                editable: _isEditing,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                'Weight',
                                _weightController,
                                editable: _isEditing,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                'Age',
                                _ageController,
                                editable: _isEditing,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                'Sleep target',
                                _sleepTargetController,
                                editable: _isEditing,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              if (state.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              if (_isEditing)
                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: state.isLoading ? null : _save,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Save changes'),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await authController.logout();
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                              ),
                            ],
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required bool editable,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: !editable,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withAlpha(editable ? 10 : 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}