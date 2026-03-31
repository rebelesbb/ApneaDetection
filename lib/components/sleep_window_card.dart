import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepWindowCard extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const SleepWindowCard({
    super.key,
    required this.start,
    required this.end,
  });

  Duration get _computedDuration {
    var diff = end.difference(start);
    if (diff <= Duration.zero) {
      diff += const Duration(hours: 24);
    }
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final duration = _computedDuration;

    return Card(
      color: Colors.white.withAlpha(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _SleepWindowPainter(
                  start: start,
                  end: end,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.nights_stay_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDurationShort(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Sleep window",
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${_formatTime(start)} - ${_formatTime(end)}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "bedtime to wake up",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  static String _formatDurationShort(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);

    if (m == 0) return "${h}h";
    return "${h}h ${m}m";
  }
}

class _SleepWindowPainter extends CustomPainter {
  final DateTime start;
  final DateTime end;

  const _SleepWindowPainter({
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const backgroundStroke = 8.0;
    const sleepStroke = 10.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - sleepStroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = backgroundStroke;

    final sleepPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = sleepStroke
      ..strokeCap = StrokeCap.round;

    final tickPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final startPointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final endPointPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    for (int i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * (math.pi / 2);
      final p1 = Offset(
        center.dx + math.cos(angle) * (radius - 7),
        center.dy + math.sin(angle) * (radius - 7),
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * (radius + 2),
        center.dy + math.sin(angle) * (radius + 2),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    final startAngle = _timeTo12HourAngle(start);
    final endAngleRaw = _timeTo12HourAngle(end);

    double sweepAngle = endAngleRaw - startAngle;
    if (sweepAngle <= 0) {
      sweepAngle += 2 * math.pi;
    }

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      sleepPaint,
    );

    final startPoint = Offset(
      center.dx + math.cos(startAngle) * radius,
      center.dy + math.sin(startAngle) * radius,
    );

    final endAngle = startAngle + sweepAngle;
    final endPoint = Offset(
      center.dx + math.cos(endAngle) * radius,
      center.dy + math.sin(endAngle) * radius,
    );

    canvas.drawCircle(startPoint, 4, startPointPaint);
    canvas.drawCircle(endPoint, 5, endPointPaint);
  }

  double _timeTo12HourAngle(DateTime dt) {
    final hour12 = dt.hour % 12;
    final totalMinutes = hour12 * 60 + dt.minute;

    return -math.pi / 2 + 2 * math.pi * (totalMinutes / 720.0);
  }

  @override
  bool shouldRepaint(covariant _SleepWindowPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}