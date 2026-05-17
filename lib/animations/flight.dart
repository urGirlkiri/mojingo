import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/widgets/emoji_widget.dart';

class TargetFlightAnimator {
  static void launch({
    required BuildContext context,
    required Offset startOffset,
    required GlobalKey targetKey,
    required GameEmoji emoji,
  }) {
    if (targetKey.currentContext == null) {
      return;
    }

    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      return;
    }

    final Offset endOffset = targetBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve:
              Curves.easeInOutBack, 
          onEnd: () => entry.remove(),
          builder: (context, value, child) {
            final double currentX =
                startOffset.dx + ((endOffset.dx - startOffset.dx) * value);
            final double currentY =
                startOffset.dy + ((endOffset.dy - startOffset.dy) * value);
            
            final double scale = 1.3 - (value * 0.8); 

            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.scale(
                scale: scale,
                child: EmojiWidget.svg(path: emoji.svg, size: 50),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(entry);
  }
}
