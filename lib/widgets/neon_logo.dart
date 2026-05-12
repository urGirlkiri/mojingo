import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/palette.dart'; 

class NeonLogo extends StatelessWidget {
  final double imageSize; 

  const NeonLogo({super.key, required this.imageSize});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final screenSize = MediaQuery.sizeOf(context);

    final double titleFontSize = (imageSize * 0.8).clamp(32.0, 72.0);
    final double subtitleFontSize = (titleFontSize * 0.35).clamp(16.0, 28.0);
    final double scale = titleFontSize / 72.0;

    final titleStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: titleFontSize,
          height: 1.0, 
        ) ?? TextStyle(fontSize: titleFontSize, height: 1.0);

    final subtitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: subtitleFontSize,
          color: palette.moonlightSoft, 
        ) ?? TextStyle(fontSize: subtitleFontSize, color: palette.moonlightSoft);

    final edgePadding = EdgeInsets.only(
      bottom: 24.0 * scale, 
      top: 12.0 * scale, 
      left: 16.0 * scale, 
      right: 16.0 * scale
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, 
              children: [
                Padding(
                  padding: edgePadding,
                  child: Text(
                    'Grimoji',
                    maxLines: 1,
                    softWrap: false,
                    style: titleStyle.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 10 * scale 
                        ..color = palette.magicCyan,
                      shadows: [
                        Shadow(blurRadius: 15 * scale, color: palette.magicCyan),
                        Shadow(blurRadius: 30 * scale, color: palette.magicCyanDeep),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: edgePadding,
                  child: Text(
                    'Grimoji',
                    maxLines: 1,
                    softWrap: false,
                    style: titleStyle.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 6 * scale
                        ..color = palette.midnight, 
                    ),
                  ),
                ),

                Padding(
                  padding: edgePadding,
                  child: Text(
                    'Grimoji',
                    maxLines: 1,
                    softWrap: false,
                    style: titleStyle.copyWith(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2.0 * scale
                        ..color = palette.trueWhite, 
                    ),
                  ),
                ),

                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        palette.trueWhite, 
                        palette.moonlightSoft,
                        palette.midnight, 
                      ],
                      stops: const [0.0, 0.4, 1.0], 
                    ).createShader(bounds);
                  },
                  child: Padding(
                    padding: edgePadding,
                    child: Text(
                      'Grimoji',
                      maxLines: 1,
                      softWrap: false,
                      style: titleStyle.copyWith(color: palette.trueWhite),
                    ),
                  ),
                ),
              ],
            ),
            screenSize.width >= 400 ?
            Text(
              'Alchemy of Emojis',
              maxLines: 1,
              softWrap: false,
              style: subtitleStyle.copyWith(
                shadows: [
                  Shadow(
                    offset: Offset(0, 2 * scale),
                    blurRadius: 4.0 * scale,
                    color: palette.voidBlack, 
                  ),
                  Shadow(
                    offset: const Offset(0, 0),
                    blurRadius: 10.0 * scale,
                    color: palette.magicCyan.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}