import 'package:flutter/material.dart';
import 'package:grimoji/utils/responsive.dart';

class ScrollDialog extends StatelessWidget {
  final Widget child;
  final Widget? rightButton;
  final Widget? leftButton;
  final EdgeInsets? padding;

  const ScrollDialog({
    super.key,
    required this.child,
    this.rightButton,
    this.leftButton,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;
    final screenSize = MediaQuery.sizeOf(context);
    final maxDialogWidth = screenSize.width * 0.9;
    final maxDialogHeight = screenSize.height * 0.8;
    final dialogWidth = isLarge ? 677.0 : maxDialogWidth.clamp(280.0, 677.0);
    final dialogHeight = isLarge ? 1000.0 : maxDialogHeight.clamp(400.0, 818.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: dialogWidth,
        maxHeight: dialogHeight,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/scroll.png',
            fit: BoxFit.fill,
            width: dialogWidth,
            height: dialogHeight,
          ),
          Padding(
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: isLarge ? 50.0 : 24.0,
              vertical: isLarge ? 40.0 : 32.0,
            ),
            child: SizedBox.expand(child: child),
          ),
          if (rightButton != null)
            Positioned(
              top: isLarge ? -15 : -8,
              right: isLarge ? -1 : -8,
              child: SizedBox(
                width: isLarge ? 80 : 60,
                height: isLarge ? 80 : 60,
                child: rightButton!,
              ),
            ),
          if (leftButton != null)
            Positioned(
              top: isLarge ? -15 : -8,
              left: isLarge ? -1 : -8,
              child: SizedBox(
                width: isLarge ? 80 : 60,
                height: isLarge ? 80 : 60,
                child: leftButton!,
              ),
            ),
        ],
      ),
    );
  }
}