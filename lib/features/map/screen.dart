import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import 'package:mojingo/features/map/widgets/level_node.dart';

class LevelsMapScreen extends StatefulWidget {
  const LevelsMapScreen({super.key});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  late final List<PointModel> _points;

  @override
  void initState() {
    super.initState(); 
    
    _points = List.generate(
      1,
      (index) => PointModel(100, LevelNode(level: index + 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/images/map/map_visual.png",
        imageWidth: 755,
        imageHeight: 1967,
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: 25,
        pointsPositionDeltaY: 25,
        svgUrl: 'assets/images/map/map_coordinates.svg',
        points: _points,
      ),
    );
  }
}
