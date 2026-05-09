import 'package:flutter/material.dart';
import 'package:grimoji/utils/responsive.dart';

class ScrollDialog extends StatelessWidget {
  final Widget child;
  final Widget? rightButton;
  final Widget? leftButton;

  const ScrollDialog({
    super.key,
    required this.child,
    this.rightButton,
    this.leftButton,
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

          if (rightButton != null)
            Positioned(
              top: isLarge ? -15 : -1,
              right: isLarge ? -1 : -1,
              child: rightButton!,
            ),
          if (leftButton != null)
            Positioned(
              top: isLarge ? -15 : -1,
              left: isLarge ? -1 : -1,
              child: leftButton!,
            ),
        ],
      ),
    );
  }
}