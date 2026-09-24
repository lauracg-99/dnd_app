import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/l10n/app_localizations.dart';

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
    expect(
      AppLocalizations.of(context)!.signInBackupDescription,
      'Sign in to backup your data and access it from anywhere',
    );
    expect(AppLocalizations.of(context)!.cloudSyncOptions, 'Cloud Sync Options');
    expect(AppLocalizations.of(context)!.syncNow, 'Sync Now');
    expect(
      AppLocalizations.of(context)!.accountDeletedSuccessfully,
      'Account deleted successfully',
    );
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
    expect(AppLocalizations.of(context)!.cloudSyncOptions, 'Opciones de sincronización');
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
}
