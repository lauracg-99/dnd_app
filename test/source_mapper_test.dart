import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/utils/source_mapper.dart';

void main() {
  group('SourceMapper Tests', () {
    test('should map common abbreviations to full book names', () {
      expect(SourceMapper.getFullBookName('phb'), equals('Player\'s Handbook'));
      expect(SourceMapper.getFullBookName('xge'), equals('Xanathar\'s Guide to Everything'));
      expect(SourceMapper.getFullBookName('tce'), equals('Tasha\'s Cauldron of Everything'));
      expect(SourceMapper.getFullBookName('scag'), equals('Sword Coast Adventurer\'s Guide'));
      expect(SourceMapper.getFullBookName('egw'), equals('Explorer\'s Guide to Wildemount'));
      expect(SourceMapper.getFullBookName('vrgr'), equals('Van Richten\'s Guide to Ravenloft'));
      expect(SourceMapper.getFullBookName('ftd'), equals('Fizban\'s Treasury of Dragons'));
      expect(SourceMapper.getFullBookName('mpmm'), equals('Mordenkainen\'s Monsters of the Multiverse'));
      expect(SourceMapper.getFullBookName('scc'), equals('Strixhaven: A Curriculum of Chaos'));
    });

    test('should handle case insensitive input', () {
      expect(SourceMapper.getFullBookName('PHB'), equals('Player\'s Handbook'));
      expect(SourceMapper.getFullBookName('TCE'), equals('Tasha\'s Cauldron of Everything'));
      expect(SourceMapper.getFullBookName('XgE'), equals('Xanathar\'s Guide to Everything'));
    });

    test('should handle whitespace in input', () {
      expect(SourceMapper.getFullBookName(' phb '), equals('Player\'s Handbook'));
      expect(SourceMapper.getFullBookName('  tce'), equals('Tasha\'s Cauldron of Everything'));
      expect(SourceMapper.getFullBookName('xge  '), equals('Xanathar\'s Guide to Everything'));
    });

    test('should return original string for unknown sources', () {
      expect(SourceMapper.getFullBookName('unknown'), equals('Unknown'));
      expect(SourceMapper.getFullBookName('custom'), equals('custom'));
      expect(SourceMapper.getFullBookName(''), equals(''));
    });

    test('should correctly identify known sources', () {
      expect(SourceMapper.isKnownSource('phb'), isTrue);
      expect(SourceMapper.isKnownSource('tce'), isTrue);
      expect(SourceMapper.isKnownSource('unknown'), isTrue);
      expect(SourceMapper.isKnownSource('custom'), isFalse);
      expect(SourceMapper.isKnownSource(''), isFalse);
    });

    test('should get abbreviation from full book name', () {
      expect(SourceMapper.getAbbreviation('Player\'s Handbook'), equals('phb'));
      expect(SourceMapper.getAbbreviation('Tasha\'s Cauldron of Everything'), equals('tce'));
      expect(SourceMapper.getAbbreviation('Xanathar\'s Guide to Everything'), equals('xge'));
    });

    test('should handle case insensitive abbreviation lookup', () {
      expect(SourceMapper.getAbbreviation('player\'s handbook'), equals('phb'));
      expect(SourceMapper.getAbbreviation('TASHA\'S CAULDRON OF EVERYTHING'), equals('tce'));
    });

    test('should return original string for unknown book names', () {
      expect(SourceMapper.getAbbreviation('Unknown Book'), equals('Unknown Book'));
      expect(SourceMapper.getAbbreviation('Custom Content'), equals('Custom Content'));
    });

    test('should provide all source abbreviations', () {
      final abbreviations = SourceMapper.getAllSourceAbbreviations();
      expect(abbreviations, contains('phb'));
      expect(abbreviations, contains('tce'));
      expect(abbreviations, contains('xge'));
      expect(abbreviations.length, equals(15)); // All mapped sources
    });

    test('should provide all book names', () {
      final bookNames = SourceMapper.getAllBookNames();
      expect(bookNames, contains('Player\'s Handbook'));
      expect(bookNames, contains('Tasha\'s Cauldron of Everything'));
      expect(bookNames, contains('Xanathar\'s Guide to Everything'));
      expect(bookNames.length, equals(15)); // All mapped sources
    });
  });
}
