import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(AppConstants.themeModePrefKey);
    switch (value) {
      case AppConstants.themeModeLight:
        return ThemeMode.light;
      case AppConstants.themeModeDark:
        return ThemeMode.dark;
      case AppConstants.themeModeSystem:
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setString(AppConstants.themeModePrefKey, _serialize(mode));
    emit(mode);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppConstants.themeModeLight;
      case ThemeMode.dark:
        return AppConstants.themeModeDark;
      case ThemeMode.system:
        return AppConstants.themeModeSystem;
    }
  }
}
