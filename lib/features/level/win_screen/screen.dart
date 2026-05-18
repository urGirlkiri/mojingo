import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/routes.dart';
import 'package:grimoji/features/level/widgets/confetti.dart';
import 'package:grimoji/features/level/win_screen/flying_star.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class WinGameScreen extends StatefulWidget {
  final int level;
  final int stars;

  const WinGameScreen({super.key, required this.level, required this.stars});

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final nextLevelNumber = widget.level + 1;
        final hasNextLevel = gameLevels.any((l) => l.number == nextLevelNumber);
        if (hasNextLevel) {
          GoRouter.of(context).goNamed(
            Routes.map,
            queryParameters: {'autoOpen': nextLevelNumber.toString()},
          );
        } else {
          GoRouter.of(context).goNamed(Routes.map);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.twilight,
      body: Stack(
        children: [
          const SizedBox.expand(child: Confetti(isStopped: false)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        'VICTORY!!',
                        style: GoogleFonts.eagleLake(
                          color: palette.trueWhite,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: palette.midnight,
                              offset: const Offset(4, 4),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < widget.stars; i++)
                        FlyingStar(index: i, total: widget.stars),
                    ],
                  ),
                ),

                Flexible(
                  child: Lottie.asset(
                    'assets/lottie/star-witch.json',
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
