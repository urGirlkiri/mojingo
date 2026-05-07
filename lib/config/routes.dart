import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'Map', icon: Icons.map),
  Destination(label: 'Recipes', icon: Icons.air), 
  Destination(label: 'Friends', icon: Icons.people),
  Destination(label: 'Market', icon: Icons.store),
];

class Routes{
  static const home = '/';
  static const levelsMap = '/play';
  static const settings = '/settings';
  static const friends = '/friends';
  static const market = '/market';
  static const bounties = '/bounties';
}