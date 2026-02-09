import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tracker/bloc/theme/theme_cubit.dart';

void main() {
  test('loads theme from shared preferences', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();

    final cubit = ThemeCubit(prefs);

    expect(cubit.state, ThemeMode.dark);
  });

  test('toggle persists theme', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final cubit = ThemeCubit(prefs);
    await cubit.toggle();

    expect(cubit.state, ThemeMode.light);
    expect(prefs.getString('theme_mode'), 'light');
  });
}
