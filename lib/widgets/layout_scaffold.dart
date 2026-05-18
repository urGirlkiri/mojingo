import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/config/routes.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/utils/responsive.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final isLarge = context.isLargeScreen;

    final double navHeight = isLarge ? 120.0 : 85.0;

    final double iconBaseSize = isLarge ? 100.0 : 60.0;
    final double iconSelectedSize = isLarge ? 120.0 : 80.0;

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: navigationShell,
      bottomNavigationBar: Container(
        height: navHeight,
        decoration: BoxDecoration(
          color: palette.midnight,
          border: Border(
            top: BorderSide(color: palette.twilight, width: isLarge ? 10 : 3),
          ),
        ),
        child: RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: destinations.asMap().entries.map((entry) {
              final int index = entry.key;
              final Destination dest = entry.value;
              final bool isSelected = navigationShell.currentIndex == index;
          
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<AudioController>().playSfx(SfxType.buttonTap);
                    navigationShell.goBranch(index);
                  },
                  child: SizedBox(
                    height: navHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          top: isSelected ? -15.0 : 20.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutBack,
                            width: isSelected ? iconSelectedSize : iconBaseSize,
                            child: Image.asset(
                              dest.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
          
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          bottom: isSelected ? 5.0 : -20.0,
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
      ),
    );
  }
}
