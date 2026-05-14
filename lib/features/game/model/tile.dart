import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:uuid/uuid.dart';

class Tile {
  final String id;
  TileCoordinate coordinate;
  TileCoordinate? hintPartner;
  GameEmoji emoji;
  
  EmojiBehavior? behavior;

  bool isExploding = false; 
  bool isMerging = false;
  bool hasFlown = false;
  bool isFlying = false; 
  bool isHinting = false;
  

  Tile({required this.coordinate, required this.emoji, String? id, this.behavior})
    : id = id ?? const Uuid().v4();

  void reset() {
    isExploding = false;
    isMerging = false;
    hasFlown = false; 
    isFlying = false; 
    isHinting = false;   
    hintPartner = null;  
  }

  void clearBehavior() {
    behavior = null;
  }

@override
  String toString() => 'Tile(${coordinate.row}, ${coordinate.col}: ${emoji.visual})';
}