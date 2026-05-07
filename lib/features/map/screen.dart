import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import 'package:mojingo/features/game/logic/levels.dart';
import 'package:mojingo/features/map/level_data_controller.dart';
import 'package:mojingo/features/map/widgets/level_node.dart';
import 'package:mojingo/features/map/widgets/level_start_dialog.dart';

import 'package:mojingo/utils/responsive.dart';
import 'package:provider/provider.dart';

class LevelsMapScreen extends StatefulWidget {
  final int? autoOpenLevel;

  const LevelsMapScreen({super.key, this.autoOpenLevel});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  late final List<PointModel> _points;

@override
  void initState() {
    super.initState();

    final levelData = context.read<LevelDataController>();

    _points = List.generate(
      gameLevels.length,
      (index) {
        final levelNum = index + 1;
        final stars = levelData.getStars(levelNum);
        
        final isUnlocked = levelNum == 1 || levelData.isLevelCompleted(levelNum - 1);

        return PointModel(100,
        isUnlocked ? LevelNode(
          level: levelNum, 
          stars: stars, 
        ) : null);
      }
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
     if (widget.autoOpenLevel != null) {
        _autoShowLevelDialog(widget.autoOpenLevel!);
      }
    });
  }

  void _autoShowLevelDialog(int levelNumber) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .7),
      builder: (BuildContext context) {
        return LevelStartDialog(level: levelNumber, targetEmoji: "☁️");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;
    final double nudgeX = isLarge ? -15.0 : 0.0;

    return Scaffold(
      body: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/images/map/map_visual.png",
        imageWidth: 755,
        imageHeight: 1967,
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: nudgeX,
        pointsPositionDeltaY: 0,
        svgUrl: 'assets/images/map/map_coordinates.svg',
        points: _points,
      ),
    );
  }
}
