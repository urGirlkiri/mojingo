import 'package:flutter/material.dart';

class IconToggle extends StatelessWidget {
  final String imagePath;
  final bool isActive;
  final VoidCallback onTap;

  const IconToggle({
    super.key,
    required this.imagePath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive ? 1.0 : 0.4,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: 80,
          height: 80,
        ),
      ),
    );
  }
}
