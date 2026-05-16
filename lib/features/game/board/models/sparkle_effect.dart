import 'package:flutter/material.dart';

class SparkleEffect {
  final String id;
  final Offset position;
  SparkleEffect({required this.position}) : id = UniqueKey().toString();
}
