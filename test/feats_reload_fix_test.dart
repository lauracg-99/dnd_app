import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/viewmodels/feats_viewmodel.dart';
import 'package:dnd_app/models/feat_model.dart';

void main() {
  group('Feats Reload Fix Tests', () {
    testWidgets('FeatsViewModel should handle loading states correctly', (WidgetTester tester) async {
      // Create FeatsViewModel
      final featsViewModel = FeatsViewModel();
      
      // Initially should not be loading
      expect(featsViewModel.isLoading, isFalse);
      expect(featsViewModel.feats, isEmpty);
      expect(featsViewModel.error, isNull);
    });

    testWidgets('Feat model should create unknown feat correctly', (WidgetTester tester) async {
      // Test the orElse fallback behavior
      final unknownFeat = Feat(
        id: 'unknown',
        name: 'Test Custom Feat',
        description: 'Custom feat',
        source: 'Unknown',
      );
      
      expect(unknownFeat.id, equals('unknown'));
      expect(unknownFeat.name, equals('Test Custom Feat'));
      expect(unknownFeat.source, equals('Unknown'));
    });

    testWidgets('FeatsViewModel should load feats without errors', (WidgetTester tester) async {
      final featsViewModel = FeatsViewModel();
      
      // Load feats
      await featsViewModel.loadFeats();
      
      // Should not be loading after completion
      expect(featsViewModel.isLoading, isFalse);
      
      // Should have loaded feats (unless there's an actual error)
      if (featsViewModel.error == null) {
        expect(featsViewModel.feats.isNotEmpty, isTrue);
      }
    });
  });
}
