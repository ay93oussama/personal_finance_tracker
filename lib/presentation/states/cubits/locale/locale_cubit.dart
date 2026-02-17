import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/constants/app_constants.dart';
import 'package:tracker/core/localization/app_locales.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_loadLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(AppConstants.localeCodePrefKey);
    return AppLocales.fromLanguageCode(code);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(AppConstants.localeCodePrefKey, locale.languageCode);
    emit(locale);
  }

  Future<void> toggle() async {
    final next = AppLocales.toggle(state);
    await setLocale(next);
  }
}
