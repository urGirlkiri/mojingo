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

  Color _getAuraColor(String text, Palette palette) {
    if (text.contains("Calamity") || text.contains("Catastrophic")) {
      return palette.crimson;
    }
    return palette.twilight;
  }

  static final _scaleSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.2,
        end: 1.2,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 8,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.2,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 6,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 78),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInBack)),
      weight: 8,
    ),
  ]);

  static final _opacitySequence = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 6),
    TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 88),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 6),
  ]);

  static final _yOffsetSequence = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 40.0, end: 0.0), weight: 8),
    TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 84),
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -50.0), weight: 8),
  ]);

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();
    final glowColor = _getAuraColor(phrase, palette);

    final double baseFontSize = phrase.length > 18 ? 32.0 : 48.0;
    final double scaleFactor = baseFontSize / 20.0;

    final baseTextStyle = GoogleFonts.eagleLake(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5 * scaleFactor,
      height: 1.1,
    );

    final edgePadding = EdgeInsets.only(
      bottom: 16.0 * scaleFactor,
      top: 8.0 * scaleFactor,
      left: 14.0 * scaleFactor,
      right: 14.0 * scaleFactor,
    );

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TweenAnimationBuilder<double>(
          key: ValueKey(animationToken),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 2500),
          builder: (context, value, child) {
            final scale = _scaleSequence.transform(value);
            final opacity = _opacitySequence.transform(value);
            final yOffset = _yOffsetSequence.transform(value);

            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: edgePadding,
                          child: Text(
                            phrase,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: baseTextStyle.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 10.0 * scaleFactor
                                ..color = glowColor,
                              shadows: [
                                Shadow(
                                  blurRadius: 15 * scaleFactor,
                                  color: glowColor,
                                ),
                                Shadow(
                                  blurRadius: 30 * scaleFactor,
                                  color: palette.midnight,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: edgePadding,
                          child: Text(
                            phrase,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: baseTextStyle.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6.0 * scaleFactor
                                ..color = palette.midnight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: edgePadding,
                          child: Text(
                            phrase,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: baseTextStyle.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.0 * scaleFactor
                                ..color = palette.slate,
                            ),
                          ),
                        ),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                palette.slate,
                                palette.moonlightSoft,
                                palette.midnight,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ).createShader(bounds);
                          },
                          child: Padding(
                            padding: edgePadding,
                            child: Text(
                              phrase,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              softWrap: false,
                              style: baseTextStyle.copyWith(
                                color: palette.slate,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}