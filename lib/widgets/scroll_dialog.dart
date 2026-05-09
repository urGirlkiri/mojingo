import 'package:flutter/material.dart';
import 'package:grimoji/utils/responsive.dart';

class ScrollDialog extends StatelessWidget {
  final Widget child;
  final Widget? closeButton;

  const ScrollDialog({
    super.key,
    required this.child,
    this.closeButton,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;

    return SizedBox(
      width: 677,
      height: isLarge ? 818 : 400,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/level/scroll.png',
            fit: BoxFit.fitWidth,
            width: 677,
            height: 818,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 40.0,
            ),
            child: child, 
          ),

          if (closeButton != null)
            Positioned(
              top: isLarge ? 20 : -1,
              right: isLarge ? 80 : -1,
              child: closeButton!,
            ),
        ],
      ),
    );
  }
}