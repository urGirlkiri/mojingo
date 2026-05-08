import 'package:flutter/material.dart';
import 'package:mojingo/config/palette.dart';
import 'package:mojingo/features/map/level_fail/dialog.dart';
import 'package:provider/provider.dart';

class LevelFailScreen extends StatefulWidget {
  final int level;

  const LevelFailScreen({
    super.key,
    required this.level,
  });

  @override
  State<LevelFailScreen> createState() => _LevelFailScreenState();
}

class _LevelFailScreenState extends State<LevelFailScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFailDialog();
    });
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .7),
      builder: (BuildContext context) {
        return LevelFailDialog(level: widget.level);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.midnight,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: palette.twilight,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/emo_3.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
