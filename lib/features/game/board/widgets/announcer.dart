import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/palette.dart';
import 'package:provider/provider.dart';

class AnnouncerWidget extends StatelessWidget {
  final String phrase;
  final int animationToken;

  const AnnouncerWidget({
    super.key,
    required this.phrase,
    required this.animationToken,
  });

  static final _scaleSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.2,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.2, end: 1.0),
      weight: 45, 
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1.0),
      weight: 30, 
    ),
  ]);

  static final _opacitySequence = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
    TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
  ]);

  static final _yOffsetSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween<double>(0.0),
      weight: 70, 
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 45.0),
      weight: 30, 
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(animationToken),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1400),
        builder: (context, value, child) {
          
          final scale = _scaleSequence.transform(value);
          final opacity = _opacitySequence.transform(value);
          final yOffset = _yOffsetSequence.transform(value);

          return Center(
            child: Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    phrase,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.eagleLake(
                      color: palette.dusk,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: palette.twilight,
                          offset: const Offset(-3, -3),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: palette.midnight,
                          offset: const Offset(3, -3),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: palette.voidBlack,
                          offset: const Offset(3, 3),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: palette.voidBlack,
                          offset: const Offset(-3, 3),
                          blurRadius: 4,
                        ),
                        Shadow(
                          color: palette.voidBlack,
                          offset: const Offset(0, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
