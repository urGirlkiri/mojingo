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
  bool isMergePoint = false;

  bool hasFlown = false;
  bool isFlying = false; 
  bool isHinting = false;
  
  Tile({required this.coordinate, required this.emoji, String? id, this.behavior})
    : id = id ?? const Uuid().v4();

  Tile copyWith({
    TileCoordinate? coordinate,
    GameEmoji? emoji,
    EmojiBehavior? behavior,
  }) {
    final newTile = Tile(
      id: id,
      coordinate: coordinate ?? this.coordinate,
      emoji: emoji ?? this.emoji,
      behavior: behavior ?? this.behavior,
    );
    
    newTile.isExploding = isExploding;
    newTile.isMerging = isMerging;
    newTile.hasFlown = hasFlown;
    newTile.isFlying = isFlying;
    newTile.isHinting = isHinting;
    newTile.hintPartner = hintPartner;
    newTile.isMergePoint = isMergePoint;
    
    return newTile;
  }

  void reset() {
    isExploding = false;
    isMerging = false;
    isMergePoint = false;
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