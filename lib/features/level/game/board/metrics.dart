import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class BoardMetrics extends ChangeNotifier {
  double? tileWidth;
  double? tileHeight;
  Rect? boardRect;

  final _logger = Logger('BoardMetrics');

  bool get isReady =>
      tileWidth != null && tileHeight != null && boardRect != null;

  void updateMetrics(double width, double height, Rect rect) {
    tileWidth = width;
    tileHeight = height;
    boardRect = rect;
    _logger.info(
      'Updated BoardMetrics: tileWidth=$tileWidth, tileHeight=$tileHeight, boardRect=$boardRect',
    );
    Future.delayed(Duration(seconds: 1), () => notifyListeners());
  }
}
