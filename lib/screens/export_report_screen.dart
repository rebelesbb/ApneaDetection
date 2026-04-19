import 'package:apnea_detector/components/background_gradient.dart';
import 'package:apnea_detector/controllers/export_report_controller.dart';
import 'package:apnea_detector/core/dependency_injector.dart';
import 'package:apnea_detector/models/report_models.dart';
import 'package:flutter/material.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  late final ExportReportController controller;

  DateTime? _startDate;
  DateTime? _endDate;
  ChartMode _chartMode = ChartMode.last7Days;
  String? _localError;

  @override
  void initState() {
    super.initState();
    controller = DI.I.exportReportController;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now.subtract(const Duration(days: 7)),
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _localError = null;
    });

    if (_startDate == null || _endDate == null) {
      setState(() {
        _localError = 'Please select both start date and end date.';
      });
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _localError = 'End date must be after start date.';
      });
      return;
    }

    if (_endDate!.difference(_startDate!).inDays > 31) {
      setState(() {
        _localError = 'The export interval cannot exceed 31 days.';
      });
      return;
    }

    await controller.generateAndOpenPdf(
      startDate: _startDate!,
      endDate: _endDate!,
      chartMode: _chartMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final state = controller.state;

        return Stack(
          children: [
            const BackgroundGradient(alignment: Alignment.topLeft),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('Export PDF Report'),
                backgroundColor: Colors.transparent,
              ),
              body: SingleChildScrollView(
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
                          'Generate Sleep Report',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an interval of up to 31 days and choose how many detailed charts to include.',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ListTile(
                          title: Text(
                            _startDate == null
                                ? 'Select start date'
                                : 'Start: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          ),
                          trailing: const Icon(Icons.date_range),
                          onTap: _pickStartDate,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(
                            _endDate == null
                                ? 'Select end date'
                                : 'End: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          ),
                          trailing: const Icon(Icons.date_range),
                          onTap: _pickEndDate,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<ChartMode>(
                          value: _chartMode,
                          decoration: const InputDecoration(
                            labelText: 'Detailed charts',
                          ),
                          items: ChartMode.values.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(mode.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _chartMode = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: state.isLoading ? null : _generateReport,
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Generate PDF'),
                          ),
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
}