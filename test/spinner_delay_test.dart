import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';

void main() {
  group('Spinner Delay Tests', () {
    test('CharactersViewModel should have loading delay', () async {
      final viewModel = CharactersViewModel();
      
      // Start loading
      final startTime = DateTime.now();
      viewModel.loadCharacters();
      
      // Should be loading immediately
      expect(viewModel.isLoading, isTrue);
      
      // Wait for loading to complete
      while (viewModel.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Should take at least 500ms due to our delay
      expect(duration.inMilliseconds, greaterThanOrEqualTo(500));
      
      // Should not be loading anymore
      expect(viewModel.isLoading, isFalse);
    });
  });
}
