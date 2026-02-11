import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/localization/app_localizations.dart';
import 'package:tracker/core/theme/app_theme.dart';
import 'package:tracker/data/models/transaction_model.dart';
import 'package:tracker/data/repositories/transaction_repository_impl.dart';
import 'package:tracker/presentation/states/cubits/locale/locale_cubit.dart';
import 'package:tracker/presentation/states/cubits/theme/theme_cubit.dart';
import 'package:tracker/presentation/states/cubits/transactions/transactions_cubit.dart';
import 'package:tracker/presentation/views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final prefs = await SharedPreferences.getInstance();
  final repository = await TransactionRepositoryImpl.create();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(prefs)),
        BlocProvider(create: (_) => LocaleCubit(prefs)),
        BlocProvider(create: (_) => TransactionsCubit(repository)..load()),
      ],
      child: const TrackerApp(),
    ),
  );
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final locale = context.select((LocaleCubit cubit) => cubit.state);
        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.financeTracker,
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: themeMode,
          theme: AppTheme.build(Brightness.light),
          darkTheme: AppTheme.build(Brightness.dark),
          home: const HomePage(),
        );
      },
    );
  }
}
