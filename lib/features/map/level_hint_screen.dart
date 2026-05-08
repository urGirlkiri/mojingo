import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mojingo/config/palette.dart';

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
    // Auto-navigate to the actual game session after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Replace current route so the player can't use the Android "Back" button to return to the hint
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
            child: Image.asset(
              'assets/images/emo_2.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("🧪", style: TextStyle(fontSize: 80)),
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