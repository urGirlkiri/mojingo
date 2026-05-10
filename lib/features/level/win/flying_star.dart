import 'dart:math';
import 'package:flutter/material.dart';

class FlyingStar extends StatelessWidget {
  final int index;
  final int total;

  const FlyingStar({super.key, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    double xSpread = total > 1 ? (index - (total - 1) / 2) : 0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)), 
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        double xPos = xSpread * 80 * value;
        
        double yPos = -sin(pi * value) * 50; 
        
        double rotation = (1.0 - value) * 2;

        return Transform.translate(
          offset: Offset(xPos, yPos),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: value * 1.5,
              child: Image.asset(
                'assets/images/level/star.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
        );
      },
    );
  }
}