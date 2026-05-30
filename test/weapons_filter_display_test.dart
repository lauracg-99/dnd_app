import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/views/information/weapons_screen.dart';
import 'package:dnd_app/viewmodels/weapons_viewmodel.dart';

void main() {
  group('WeaponsScreen Filter Display', () {
    testWidgets('should display active filters when search query is set', (WidgetTester tester) async {
      // Create a test viewModel
      final viewModel = WeaponsViewModel();
      
      // Create a test widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Set a search query
      viewModel.setSearchQuery('sword');
      await tester.pump();
      
      // Verify the filter display appears
      expect(find.text('Active Filters:'), findsOneWidget);
      expect(find.text('Search: "sword"'), findsOneWidget);
    });
    
    testWidgets('should display active filters when type filter is set', (WidgetTester tester) async {
      final viewModel = WeaponsViewModel();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Set a type filter
      viewModel.setSelectedType('Martial');
      await tester.pump();
      
      // Verify the filter display appears
      expect(find.text('Active Filters:'), findsOneWidget);
      expect(find.text('Type: Martial'), findsOneWidget);
    });
    
    testWidgets('should display both filters when both are set', (WidgetTester tester) async {
      final viewModel = WeaponsViewModel();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Set both filters
      viewModel.setSearchQuery('sword');
      viewModel.setSelectedType('Martial');
      await tester.pump();
      
      // Verify both filters are displayed
      expect(find.text('Active Filters:'), findsOneWidget);
      expect(find.text('Search: "sword"'), findsOneWidget);
      expect(find.text('Type: Martial'), findsOneWidget);
    });
    
    testWidgets('should not display filters when none are active', (WidgetTester tester) async {
      final viewModel = WeaponsViewModel();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Verify no filter display appears
      expect(find.text('Active Filters:'), findsNothing);
    });
    
    testWidgets('should clear individual filters when chip is tapped', (WidgetTester tester) async {
      final viewModel = WeaponsViewModel();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Set a search query
      viewModel.setSearchQuery('sword');
      await tester.pump();
      
      // Tap the close button on the search chip
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      // Verify the filter is cleared
      expect(find.text('Active Filters:'), findsNothing);
      expect(viewModel.searchQuery, isEmpty);
    });
    
    testWidgets('should clear all filters when Clear All is tapped', (WidgetTester tester) async {
      final viewModel = WeaponsViewModel();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeaponsViewModel>(
            create: (_) => viewModel,
            child: const WeaponsScreen(),
          ),
        ),
      );
      
      // Set both filters
      viewModel.setSearchQuery('sword');
      viewModel.setSelectedType('Martial');
      await tester.pump();
      
      // Tap the Clear All button
      await tester.tap(find.text('Clear All'));
      await tester.pump();
      
      // Verify all filters are cleared
      expect(find.text('Active Filters:'), findsNothing);
      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.selectedType, 'All');
    });
  });
}
