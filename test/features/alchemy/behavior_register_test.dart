import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

void main() {
  group('BehaviorRegister Tests', () {
    
    final emojisWithBehaviors = BehaviorRegister.getAllEmojisWithBehaviors();

    test('Should correctly identify and build mapped behaviors', () {
      for (final emoji in emojisWithBehaviors) {
        expect(BehaviorRegister.hasBehavior(emoji), isTrue,
            reason: '${emoji.visual} should be registered in BehaviorRegister');
        
        final behavior = BehaviorRegister.getBehaviorFor(emoji);
        expect(behavior, isNotNull);
        expect(behavior, isA<EmojiBehavior>(), 
            reason: 'Builder must return a valid EmojiBehavior instance');
      }
    });

    test('Should return null for normal emojis', () {
      expect(BehaviorRegister.hasBehavior(Emojis.rock), isFalse, 
          reason: 'Emojis.rock should not have a registered behavior');
      expect(BehaviorRegister.getBehaviorFor(Emojis.rock), isNull, 
          reason: 'getBehaviorFor should return null for Emojis.rock');
      
      expect(BehaviorRegister.hasBehavior(Emojis.droplet), isFalse, 
          reason: 'Emojis.droplet should not have a registered behavior');
      expect(BehaviorRegister.getBehaviorFor(Emojis.droplet), isNull, 
          reason: 'getBehaviorFor should return null for Emojis.droplet');
    });

    test('All behaviors must safely handle every lifecycle event without crashing', () {
      for (final emoji in emojisWithBehaviors) {
        final behavior = BehaviorRegister.getBehaviorFor(emoji)!;
        final typeName = behavior.runtimeType.toString();
        
        expect(() => behavior.onTurnEnd(1, 1), returnsNormally, 
          reason: '$typeName crashed during onTurnEnd');
        expect(behavior.onTurnEnd(1, 1), isA<List<BehaviorAction>>(),
          reason: '$typeName onTurnEnd must return a List<BehaviorAction>');

        expect(() => behavior.onMatched(2, 2), returnsNormally,
          reason: '$typeName crashed during onMatched');
        expect(behavior.onMatched(2, 2), isA<List<BehaviorAction>>(),
          reason: '$typeName onMatched must return a List<BehaviorAction>');

        expect(() => behavior.onBlastNearby(3, 3, ReactionType.explosive), returnsNormally,
          reason: '$typeName crashed during onBlastNearby');
        expect(behavior.onBlastNearby(3, 3, ReactionType.explosive), isA<List<BehaviorAction>>(),
          reason: '$typeName onBlastNearby must return a List<BehaviorAction>');

        expect(() => behavior.onSwipedWith(4, 4, Emojis.fire), returnsNormally,
          reason: '$typeName crashed during onSwipedWith');
        expect(behavior.onSwipedWith(4, 4, Emojis.fire), isA<List<BehaviorAction>>(),
          reason: '$typeName onSwipedWith must return a List<BehaviorAction>');
      }
    });
  });
}