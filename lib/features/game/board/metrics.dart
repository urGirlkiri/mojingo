import 'package:flutter/material.dart';

class BoardMetrics extends ChangeNotifier {
  double? tileWidth;
  double? tileHeight;
  Rect? boardRect;

  bool get isReady =>
      tileWidth != null && tileHeight != null && boardRect != null;

  void updateMetrics(double width, double height, Rect rect) {
    tileWidth = width;
    tileHeight = height;
    boardRect = rect;
    notifyListeners();
  }
}
