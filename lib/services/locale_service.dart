import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class AppLocaleStorage {
  static const String _key = 'selected_locale';

  static Locale get defaultLocale => const Locale('en');

  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_key);

    if (localeCode != null &&
        AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == localeCode,
        )) {
      return Locale(localeCode);
    }

    return defaultLocale;
  }

  static Future<void> saveLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
