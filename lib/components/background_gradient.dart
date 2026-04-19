import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget{
  final Alignment alignment;
  final bool useHero;
  final String heroTag;
  const BackgroundGradient({
    super.key,
    required this.alignment,
    this.useHero = false,
    this.heroTag = 'main_gradient',
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
            center: alignment,
            radius: 2,
            colors: [
              Color.fromARGB(255, 41, 12, 81),
              Color.fromARGB(255, 99, 43, 81),
              Color.fromARGB(255, 52, 36, 62),
            ],
            ),
      ),
    );

    if (!useHero) return content;

    return Hero(
      tag: heroTag,
      child: content,
    );
  }
}