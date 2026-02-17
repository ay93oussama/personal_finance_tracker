import 'package:flutter/material.dart';
import 'package:tracker/core/localization/app_localizations_de.dart';
import 'package:tracker/core/localization/app_localizations_en.dart';
import 'package:tracker/core/localization/app_locales.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = AppLocales.supported;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static const Map<String, Map<String, String>> _values = {
    AppLocales.fallbackLanguageCode: appLocalizationsEn,
    AppLocales.secondaryLanguageCode: appLocalizationsDe,
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ??
      _values[AppLocales.fallbackLanguageCode]![key]!;

  String get financeTracker => _t('financeTracker');
  String get addTransaction => _t('addTransaction');
  String get addTransactionTitle => _t('addTransactionTitle');
  String get editTransactionTitle => _t('editTransactionTitle');
  String get save => _t('save');
  String get delete => _t('delete');
  String get deleteTransactionTitle => _t('deleteTransactionTitle');
  String get deleteTransactionBody => _t('deleteTransactionBody');
  String get cancel => _t('cancel');
  String get toggleTheme => _t('toggleTheme');
  String get toggleLanguage => _t('toggleLanguage');
  String get demo => _t('demo');
  String get spendingByCategory => _t('spendingByCategory');
  String get transactions => _t('transactions');
  String get currentBalance => _t('currentBalance');
  String get noTransactionsYet => _t('noTransactionsYet');
  String get addFirstTransaction => _t('addFirstTransaction');
  String get retry => _t('retry');
  String get somethingWentWrong => _t('somethingWentWrong');
  String get noExpensesYet => _t('noExpensesYet');
  String get showMore => _t('showMore');
  String get showLess => _t('showLess');
  String get chartHint => _t('chartHint');
  String get allDates => _t('allDates');
  String get expenses => _t('expenses');
  String get income => _t('income');
  String get selectDate => _t('selectDate');
  String get selectDateRange => _t('selectDateRange');
  String get clear => _t('clear');
  String get lastMonth => _t('lastMonth');
  String get lastQuarter => _t('lastQuarter');
  String get lastYear => _t('lastYear');
  String get start => _t('start');
  String get end => _t('end');
  String get showActivities => _t('showActivities');
  String get selectCategory => _t('selectCategory');
  String get searchCategories => _t('searchCategories');
  String get noMatchesFound => _t('noMatchesFound');
  String get amount => _t('amount');
  String get category => _t('category');
  String get date => _t('date');
  String get notesOptional => _t('notesOptional');
  String get expense => _t('expense');
  String get enterValidAmount => _t('enterValidAmount');
  String get amountRequired => _t('amountRequired');
  String get categoryRequired => _t('categoryRequired');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
