import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isLargeScreen => screenWidth > 600;

  double get globalScale => isLargeScreen ? 1.5 : 1.0;
}