import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/presentation/states/cubits/locale/locale_cubit.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return IconButton(
          tooltip: context.l10n.toggleLanguage,
          onPressed: () => context.read<LocaleCubit>().toggle(),
          icon: const Icon(Icons.language),
        );
      },
    );
  }
}
