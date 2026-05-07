import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mojingo/config/routes.dart';
import 'package:mojingo/config/palette.dart'; 

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 85, 
        decoration: BoxDecoration(
          color: palette.midnight,
          border: Border(
            top: BorderSide(color: palette.twilight, width: 3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: destinations.asMap().entries.map((entry) {
            final int index = entry.key;
            final Destination dest = entry.value;
            final bool isSelected = navigationShell.currentIndex == index;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque, 
                onTap: () => navigationShell.goBranch(index),
                child: SizedBox(
                  height: 85,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack, 
                        top: 10.0, 
                        child: Image.asset(
                          dest.imagePath,
                          width: isSelected ? 45 : 60,
                        ),
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        bottom: isSelected ? 10.0 : -20.0, 
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Text(
                            dest.label,
                            style: GoogleFonts.eagleLake(
                              color: palette.mist,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}