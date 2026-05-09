import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/logic/level_state.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  static const double progress = 0.65;

  Palette get palette => Palette();

  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: palette.mist,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBox(
                  'Time',
                  context.watch<LevelState>().secondsRemaining.toString(),
                ),
                const SizedBox(width: 16),
                _buildTargetBox(context.watch<LevelState>().level.targetEmoji),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: palette.dusk,
                    shape: CircleBorder(
                      side: BorderSide(width: 3, color: palette.dusk),
                    ),
                    image: const DecorationImage(
                      image: AssetImage("assets/mascot/wizard.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildProgressbar(
          context.watch<LevelState>().level.number.toString(),
          65,
        ),
      ],
    );
  }

  Widget _buildProgressbar(String level, double progress) {
    return Row(
      children: [
        Text(
          'Level $level',
          style: TextStyle(
            color: palette.trueWhite,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: double.infinity,
                height: 12,
                decoration: ShapeDecoration(
                  color: palette.twilight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: ShapeDecoration(
                    color: palette.mist,
                    // TODO: change color if active(when actively triggering combos n updating progress) to moonlight
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStar(isActive: progress >= 0.25),
                  _buildStar(isActive: progress >= 0.50),
                  _buildStar(isActive: progress >= 0.75),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: ShapeDecoration(
              color: palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(color: palette.trueWhite, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: palette.trueWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetBox(GameEmoji targetEmoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: ShapeDecoration(
              color: palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Target',
              style: TextStyle(color: palette.trueWhite, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          EmojiWidget.lottie(
            path: targetEmoji.lottie,
            useDropShadow: true,
            size: 40,
            blurRadius: 4,
            shadowOffset: const Offset(0, 4),
            shadowColor: palette.midnight,
          ),
        ],
      ),
    );
  }

  Widget _buildStar({required bool isActive}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.3,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/level/star.png"),
          ),
        ),
      ),
    );
  }
}
