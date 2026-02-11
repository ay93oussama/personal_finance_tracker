import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('de')];

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
    'en': {
      'financeTracker': 'Finance Tracker',
      'addTransaction': 'Add transaction',
      'addTransactionTitle': 'Add Transaction',
      'editTransactionTitle': 'Edit Transaction',
      'save': 'Save',
      'delete': 'Delete',
      'deleteTransactionTitle': 'Delete transaction?',
      'deleteTransactionBody': 'This action cannot be undone.',
      'cancel': 'Cancel',
      'toggleTheme': 'Toggle theme',
      'toggleLanguage': 'Switch language',
      'demo': 'Demo',
      'spendingByCategory': 'Spending by category',
      'transactions': 'Transactions',
      'noTransactionsYet': 'No transactions yet',
      'addFirstTransaction': 'Add your first income or expense.',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong.',
      'noExpensesYet': 'No expenses yet.',
      'showMore': 'Show more',
      'showLess': 'Show less',
      'chartHint':
          'Bars show each category as a share of total expenses for the selected date range.',
      'allDates': 'All dates',
      'expenses': 'Expenses',
      'income': 'Income',
      'selectDate': 'Select a date',
      'selectDateRange': 'Select a date range',
      'clear': 'Clear',
      'lastMonth': 'Last month',
      'lastQuarter': 'Last quarter',
      'lastYear': 'Last year',
      'start': 'Start',
      'end': 'End',
      'showActivities': 'Show activities',
      'selectCategory': 'Select a category',
      'searchCategories': 'Search categories',
      'noMatchesFound': 'No matches found.',
      'amount': 'Amount',
      'category': 'Category',
      'date': 'Date',
      'notesOptional': 'Notes (optional)',
      'expense': 'Expense',
      'enterValidAmount': 'Enter a valid amount.',
      'amountRequired': 'Amount is required.',
      'categoryRequired': 'Category is required.',
    },
    'de': {
      'financeTracker': 'Finanz-Tracker',
      'addTransaction': 'Transaktion hinzufügen',
      'addTransactionTitle': 'Transaktion hinzufügen',
      'editTransactionTitle': 'Transaktion bearbeiten',
      'save': 'Speichern',
      'delete': 'Löschen',
      'deleteTransactionTitle': 'Transaktion löschen?',
      'deleteTransactionBody': 'Diese Aktion kann nicht rückgängig gemacht werden.',
      'cancel': 'Abbrechen',
      'toggleTheme': 'Design umschalten',
      'toggleLanguage': 'Sprache wechseln',
      'demo': 'Demo',
      'spendingByCategory': 'Ausgaben nach Kategorie',
      'transactions': 'Transaktionen',
      'noTransactionsYet': 'Noch keine Transaktionen',
      'addFirstTransaction': 'Füge deine erste Einnahme oder Ausgabe hinzu.',
      'retry': 'Erneut versuchen',
      'somethingWentWrong': 'Etwas ist schiefgelaufen.',
      'noExpensesYet': 'Noch keine Ausgaben.',
      'showMore': 'Mehr anzeigen',
      'showLess': 'Weniger anzeigen',
      'chartHint':
          'Balken zeigen jede Kategorie als Anteil der Gesamtausgaben im gewählten Zeitraum.',
      'allDates': 'Alle Daten',
      'expenses': 'Ausgaben',
      'income': 'Einnahmen',
      'selectDate': 'Datum auswählen',
      'selectDateRange': 'Datumsbereich auswählen',
      'clear': 'Zurücksetzen',
      'lastMonth': 'Letzter Monat',
      'lastQuarter': 'Letztes Quartal',
      'lastYear': 'Letztes Jahr',
      'start': 'Start',
      'end': 'Ende',
      'showActivities': 'Aktivitäten anzeigen',
      'selectCategory': 'Kategorie auswählen',
      'searchCategories': 'Kategorien suchen',
      'noMatchesFound': 'Keine Treffer gefunden.',
      'amount': 'Betrag',
      'category': 'Kategorie',
      'date': 'Datum',
      'notesOptional': 'Notizen (optional)',
      'expense': 'Ausgabe',
      'enterValidAmount': 'Bitte einen gültigen Betrag eingeben.',
      'amountRequired': 'Betrag ist erforderlich.',
      'categoryRequired': 'Kategorie ist erforderlich.',
    },
  };

  String _t(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key]!;

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
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
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
