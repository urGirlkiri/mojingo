import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:provider/provider.dart';

class HintNudge extends StatefulWidget {
  final bool isHinting;
  final TileCoordinate current;
  final TileCoordinate? partner;
  final double tileWidth;
  final double tileHeight;
  final Widget child;

  const HintNudge({
    super.key,
    required this.isHinting,
    required this.current,
    this.partner,
    required this.tileWidth,
    required this.tileHeight,
    required this.child,
  });

  @override
  State<HintNudge> createState() => _HintNudgeState();
}

class _HintNudgeState extends State<HintNudge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isHinting) _controller.repeat();
  }

  @override
  void didUpdateWidget(HintNudge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHinting && !oldWidget.isHinting) {
      _controller.repeat();
    } else if (!widget.isHinting && oldWidget.isHinting) {
      _controller.reset();
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    if (!widget.isHinting || widget.partner == null) return widget.child;

    double dx = (widget.partner!.col - widget.current.col).toDouble();
    double dy = (widget.partner!.row - widget.current.row).toDouble();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double progress = sin(_animation.value);

        double moveX =
            dx * (widget.tileWidth + tileSpacingGap) * 0.4 * progress;
        double moveY =
            dy * (widget.tileHeight + tileSpacingGap) * 0.4 * progress;

        return Transform.translate(
          offset: Offset(moveX, moveY),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: palette.trueWhite.withValues(alpha: progress * 0.7),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
