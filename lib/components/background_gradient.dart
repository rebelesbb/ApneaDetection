import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget{
  final Alignment alignment;
  const BackgroundGradient({
    super.key,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'main_gradient', 
      child: Container(
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
      )
      );
  }
}