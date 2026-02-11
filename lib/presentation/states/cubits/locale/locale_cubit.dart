import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/constants/app_constants.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_loadLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(AppConstants.localeCodePrefKey) ?? 'en';
    return code == 'de' ? const Locale('de') : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(AppConstants.localeCodePrefKey, locale.languageCode);
    emit(locale);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'en'
        ? const Locale('de')
        : const Locale('en');
    await setLocale(next);
  }
}
