import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.color = Colors.cyanAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withAlpha(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}