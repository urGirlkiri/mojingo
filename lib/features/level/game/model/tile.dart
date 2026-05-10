import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:uuid/uuid.dart';

class Tile {
  final String id;
  TileCoordinate coordinate;
  GameEmoji emoji;

  bool isExploding = false; 
  bool isMerging = false;

  Tile({required this.coordinate, required this.emoji, String? id})
    : id = id ?? const Uuid().v4();

  void reset() {
    isExploding = false;
    isMerging = false;
  }

  @override
  String toString() => 'Tile(${coordinate.row}, ${coordinate.col}: ${emoji.visual})';
}
