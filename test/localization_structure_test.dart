import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dnd_app/l10n/app_localizations.dart';
import 'package:dnd_app/services/locale_service.dart';

void main() {
  testWidgets('app exposes localization delegates and english labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Center(child: Text('placeholder'))),
      ),
    );

    final context = tester.element(find.text('placeholder'));

    expect(AppLocalizations.of(context), isNotNull);
    expect(AppLocalizations.of(context)!.navCharacters, 'Characters');
    expect(AppLocalizations.of(context)!.appTitle, 'D&D');
    expect(AppLocalizations.of(context)!.language, 'Language');
    expect(AppLocalizations.of(context)!.classLabel, 'Class');
    expect(AppLocalizations.of(context)!.customSubclass, 'Custom Subclass');
    expect(
      AppLocalizations.of(context)!.subclassOptional,
      'Subclass (Optional)',
    );
    expect(AppLocalizations.of(context)!.raceOptional, 'Race (Optional)');
    expect(
      AppLocalizations.of(context)!.backgroundOptional,
      'Background (Optional)',
    );
    expect(AppLocalizations.of(context)!.creatingCharacter, 'Creating...');
    expect(
      AppLocalizations.of(context)!.signInBackupDescription,
      'Sign in to backup your data and access it from anywhere',
    );
    expect(
      AppLocalizations.of(context)!.cloudSyncOptions,
      'Cloud Sync Options',
    );
    expect(AppLocalizations.of(context)!.syncNow, 'Sync Now');
    expect(
      AppLocalizations.of(context)!.accountDeletedSuccessfully,
      'Account deleted successfully',
    );
    expect(AppLocalizations.of(context)!.searchClasses, 'Search classes...');
    expect(AppLocalizations.of(context)!.noClassesFound, 'No classes found');
    expect(AppLocalizations.of(context)!.searchWeapons, 'Search weapons...');
  });

  testWidgets('app supports spanish locale switch entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Center(child: Text('placeholder'))),
      ),
    );

    final context = tester.element(find.text('placeholder'));

    expect(AppLocalizations.of(context)!.navCharacters, 'Personajes');
    expect(AppLocalizations.of(context)!.language, 'Idioma');
    expect(AppLocalizations.of(context)!.classLabel, 'Clase');
    expect(
      AppLocalizations.of(context)!.customSubclass,
      'Subclase personalizada',
    );
    expect(
      AppLocalizations.of(context)!.subclassOptional,
      'Subclase (opcional)',
    );
    expect(AppLocalizations.of(context)!.raceOptional, 'Raza (opcional)');
    expect(
      AppLocalizations.of(context)!.backgroundOptional,
      'Trasfondo (opcional)',
    );
    expect(AppLocalizations.of(context)!.creatingCharacter, 'Creando...');
    expect(
      AppLocalizations.of(context)!.cloudSyncOptions,
      'Opciones de sincronización',
    );
    expect(AppLocalizations.of(context)!.syncNow, 'Sincronizar ahora');
    expect(
      AppLocalizations.of(context)!.languageWarningTitle,
      'Cambio de idioma',
    );
    expect(
      AppLocalizations.of(context)!.languageWarningMessage,
      'Al cambiar a español, algunos recursos como la información de los hechizos seguirán en inglés.',
    );
    expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
  });

  testWidgets('selected locale persists across restarts', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await AppLocaleStorage.saveLocale(const Locale('es'));
    final locale = await AppLocaleStorage.loadLocale();

    expect(locale, const Locale('es'));
    expect(AppLocalizations.supportedLocales, contains(locale));
  });
}
