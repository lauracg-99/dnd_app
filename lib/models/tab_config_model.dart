import 'package:flutter/material.dart';

/// Tab configuration model for character edit screen
class CharacterTabConfig {
  final String id;
  final String label;
  final IconData icon;
  final Widget Function() builder;
  final bool isVisible;
  
  const CharacterTabConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    this.isVisible = true,
  });
  
  /// Create copy with updated values
  CharacterTabConfig copyWith({
    String? id,
    String? label,
    IconData? icon,
    Widget Function()? builder,
    bool? isVisible,
  }) {
    return CharacterTabConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      builder: builder ?? this.builder,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Tab configuration manager
class CharacterTabManager {
  static final Map<String, CharacterTabConfig> _allTabs = {
    'character': CharacterTabConfig(
      id: 'character',
      label: 'Character',
      icon: Icons.shield,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'quick_guide': CharacterTabConfig(
      id: 'quick_guide',
      label: 'Quick Guide',
      icon: Icons.description,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'stats': CharacterTabConfig(
      id: 'stats',
      label: 'Stats',
      icon: Icons.bar_chart,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'skills': CharacterTabConfig(
      id: 'skills',
      label: 'Skills',
      icon: Icons.psychology,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'attacks': CharacterTabConfig(
      id: 'attacks',
      label: 'Attacks',
      icon: Icons.gavel,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'spell_slots': CharacterTabConfig(
      id: 'spell_slots',
      label: 'Spell Slots',
      icon: Icons.grid_view,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'spells': CharacterTabConfig(
      id: 'spells',
      label: 'Spells',
      icon: Icons.auto_awesome,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'feats': CharacterTabConfig(
      id: 'feats',
      label: 'Feats',
      icon: Icons.military_tech,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'class_slots': CharacterTabConfig(
      id: 'class_slots',
      label: 'Class Slots',
      icon: Icons.casino,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'appearance': CharacterTabConfig(
      id: 'appearance',
      label: 'Appearance',
      icon: Icons.face,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
    'notes': CharacterTabConfig(
      id: 'notes',
      label: 'Notes',
      icon: Icons.note,
      builder: () => throw UnimplementedError('Builder must be provided by screen'),
    ),
  };
  
  /// Get all available tab configurations
  static Map<String, CharacterTabConfig> getAllTabs() {
    return Map.from(_allTabs);
  }
  
  /// Get tab configuration by ID
  static CharacterTabConfig? getTabConfig(String id) {
    return _allTabs[id];
  }
  
  /// Update tab configuration
  static void updateTabConfig(String id, CharacterTabConfig config) {
    _allTabs[id] = config;
  }
  
  /// Get ordered tabs based on tab order list
  static List<CharacterTabConfig> getOrderedTabs(List<String> tabOrder, Map<String, Widget Function()> builders) {
    final List<CharacterTabConfig> orderedTabs = [];
    
    for (String tabId in tabOrder) {
      final config = _allTabs[tabId];
      if (config != null && config.isVisible) {
        final builder = builders[tabId];
        if (builder != null) {
          orderedTabs.add(config.copyWith(builder: builder));
        }
      }
    }
    
    // Add any visible tabs that aren't in the order list
    for (String tabId in _allTabs.keys) {
      final config = _allTabs[tabId]!;
      if (config.isVisible && !tabOrder.contains(tabId)) {
        final builder = builders[tabId];
        if (builder != null) {
          orderedTabs.add(config.copyWith(builder: builder));
        }
      }
    }
    
    return orderedTabs;
  }
  
  /// Get default tab order
  static List<String> getDefaultTabOrder() {
    return [
      'character',
      'quick_guide',
      'stats',
      'skills',
      'attacks',
      'spell_slots',
      'spells',
      'feats',
      'class_slots',
      'appearance',
      'notes',
    ];
  }
}
