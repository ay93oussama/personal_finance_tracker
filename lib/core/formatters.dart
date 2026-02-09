import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currency = NumberFormat.currency(symbol: '€');
  static final DateFormat _shortDate = DateFormat.yMMMd();
  static final DateFormat _longDate = DateFormat.yMMMMd();

  static String currency(double value) => _currency.format(value);

  static String signedCurrency(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign${_currency.format(value.abs())}';
  }

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String longDate(DateTime date) => _longDate.format(date);
}
