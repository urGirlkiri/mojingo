import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:provider/provider.dart';

class LockedCard extends StatelessWidget {
  const LockedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();

    return Container(
      decoration: BoxDecoration(
        color: palette.midnight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              'assets/images/grimoire/card-frame.png',
              fit: BoxFit.fill,

            ),
          ),

          Center(
            child: Image.asset(
              'assets/images/grimoire/queston_mark.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
