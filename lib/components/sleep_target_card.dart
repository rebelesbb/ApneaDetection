import 'package:flutter/material.dart';

class SleepTargetCard extends StatelessWidget {
  final Duration sleepDuration;
  final Duration targetDuration;

  const SleepTargetCard({
    super.key,
    required this.sleepDuration,
    this.targetDuration = const Duration(hours: 8),
  });

  @override
  Widget build(BuildContext context) {
    final percent = sleepDuration.inMinutes / targetDuration.inMinutes;
    final percentLabel = "${(percent * 100).round()}%";
    final progress = percent.clamp(0.0, 1.0);

    return Card(
      color: Colors.white.withAlpha(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(
              width: 110,
              height: 100,
              child: Center(
                child: Icon(
                  Icons.track_changes_rounded,
                  color: Colors.lightBlueAccent,
                  size: 42,
                ),
              ),
            ),
            // const SizedBox(height: 2),
            Text(
              "${_formatDuration(sleepDuration)} of ${_formatDuration(targetDuration)} goal",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Sleep target",
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              percentLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.lightBlueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) return "${minutes}m";
    if (minutes == 0) return "${hours}h";
    return "${hours}h ${minutes}m";
  }
}