import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/game/model/coordinate.dart';

void main(){
  test("Should Correctly parse equality between coordinate", (){
    final coordA = TileCoordinate(row: 0, col: 0);
    final coordB = TileCoordinate(row: 0, col: 0);
    final coordC = TileCoordinate(row: 1, col: 0);

    expect(coordA == coordB, true, reason: 'Coordinates with the same row and column should be equal');
    expect(coordA == coordC, false, reason: 'Coordinates with different rows should not be equal');
  });

  test("Should correctly hash coordinates with the same row and column to the same value", (){
    final coordA = TileCoordinate(row: 0, col: 0);
    final coordB = TileCoordinate(row: 0, col: 0);
    final coordC = TileCoordinate(row: 1, col: 0);

    expect(coordA.hashCode, coordB.hashCode, reason: 'Coordinates with the same row and column should have the same hash code');
    expect(coordA.hashCode == coordC.hashCode, false, reason: 'Coordinates with different rows should ideally have different hash codes');
  });

  test("Should be able to use coordinates as keys in a Set and Map", (){
    final coordA = TileCoordinate(row: 0, col: 0);
    final coordB = TileCoordinate(row: 0, col: 0);
    final coordC = TileCoordinate(row: 1, col: 0);

    final coordinateSet = {coordA};
    expect(coordinateSet.contains(coordB), true, reason: 'Set should recognize coordB as equal to coordA and contain it');
    expect(coordinateSet.contains(coordC), false, reason: 'Set should not recognize coordC as equal to coordA and should not contain it');

    final coordinateMap = {coordA: 'Tile A'};
    expect(coordinateMap[coordB], 'Tile A', reason: 'Map should recognize coordB as equal to coordA and return the associated value');
    expect(coordinateMap[coordC], null, reason: 'Map should not recognize coordC as equal to coordA and should return null');
  });


}