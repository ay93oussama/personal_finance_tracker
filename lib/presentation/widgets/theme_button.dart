import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/presentation/states/cubits/theme/theme_cubit.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final icon = mode == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode;
        return IconButton(
          tooltip: context.l10n.toggleTheme,
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: Icon(icon),
        );
      },
    );
  }
}
