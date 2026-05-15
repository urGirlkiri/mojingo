import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Emojis Test', () {
    test('All SVGs and Lotties mentioned in emojis.dart MUST exist', () {
      
      final file = File('lib/config/emojis.dart');
      expect(file.existsSync(), isTrue, reason: 'Could not find lib/config/emojis.dart');

      final fileContent = file.readAsStringSync();

      final svgRegex = RegExp(r"'([^']+\.svg)'");
      final lottieRegex = RegExp(r"'([^']+\.json)'");

      final svgPaths = svgRegex.allMatches(fileContent).map((m) => m.group(1)!).toSet();
      final lottiePaths = lottieRegex.allMatches(fileContent).map((m) => m.group(1)!).toSet();

      expect(svgPaths, isNotEmpty, reason: 'Regex failed to find any SVGs in emojis.dart');
      expect(lottiePaths, isNotEmpty, reason: 'Regex failed to find any Lotties in emojis.dart');

      for (final path in svgPaths) {
        final svgFile = File(path); 
        expect(svgFile.existsSync(), isTrue, 
          reason: 'CRITICAL: Broken SVG link found in emojis.dart -> $path');
      }

      for (final path in lottiePaths) {
        final lottieFile = File(path);
        expect(lottieFile.existsSync(), isTrue, 
          reason: 'CRITICAL: Broken Lottie link found in emojis.dart -> $path');
      }
    });
  });
}