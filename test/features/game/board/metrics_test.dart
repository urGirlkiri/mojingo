import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/game/board/metrics.dart'; 

void main() {
  group('BoardMetrics Tests', () {
    late BoardMetrics metrics;

    setUp(() {
      metrics = BoardMetrics();
    });

    test('Should start in an unready state with null values', () {
      expect(metrics.isReady, isFalse, reason: 'A fresh BoardMetrics should not be ready');
      expect(metrics.tileWidth, isNull);
      expect(metrics.tileHeight, isNull);
      expect(metrics.boardRect, isNull);
    });

    test('updateMetrics should correctly assign all dimensions and mark as ready', () {
      const fakeRect = Rect.fromLTWH(0, 0, 400, 800);

      metrics.updateMetrics(50.0, 50.0, fakeRect);

      expect(metrics.isReady, isTrue, reason: 'After receiving data, it must be ready');
      expect(metrics.tileWidth, equals(50.0));
      expect(metrics.tileHeight, equals(50.0));
      expect(metrics.boardRect, equals(fakeRect));
    });

    test('updateMetrics MUST trigger notifyListeners()', () {
      bool wasNotified = false;
      metrics.addListener(() {
        wasNotified = true;
      });

      metrics.updateMetrics(50.0, 50.0, const Rect.fromLTWH(0, 0, 400, 800));

      expect(wasNotified, isTrue, reason: 'If notifyListeners is skipped, the UI will never draw the board');
    });
  });
}