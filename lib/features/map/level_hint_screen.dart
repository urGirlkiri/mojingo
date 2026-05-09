import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';

class LevelHintScreen extends StatefulWidget {
  final int level;
  const LevelHintScreen({super.key, required this.level});

  @override
  State<LevelHintScreen> createState() => _LevelHintScreenState();
}

class _LevelHintScreenState extends State<LevelHintScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        GoRouter.of(context).replace('/play/session/${widget.level}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmojiWidget.lottie(
                  path: Emojis.cooking.lottie,
                  useDropShadow: true,
                  size: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  "Gathering ingredients...",
                  style: GoogleFonts.caudex(color: palette.mist, fontSize: 24),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
