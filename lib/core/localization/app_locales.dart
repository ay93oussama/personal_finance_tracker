import 'package:flutter/material.dart';

class AppLocales {
  AppLocales._();

  static const String fallbackLanguageCode = 'en';
  static const String secondaryLanguageCode = 'de';

  static const Locale fallback = Locale(fallbackLanguageCode);
  static const Locale secondary = Locale(secondaryLanguageCode);
  static const List<Locale> supported = [fallback, secondary];

  static Locale fromLanguageCode(String? code) {
    if (code == secondaryLanguageCode) {
      return secondary;
    }
    return fallback;
  }

  static Locale toggle(Locale current) {
    return current.languageCode == fallbackLanguageCode ? secondary : fallback;
  }
}
