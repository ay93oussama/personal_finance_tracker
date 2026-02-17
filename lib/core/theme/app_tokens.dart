import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.income, required this.expense});

  final Color income;
  final Color expense;

  @override
  AppSemanticColors copyWith({Color? income, Color? expense}) {
    return AppSemanticColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
    );
  }
}

extension AppThemeDataX on ThemeData {
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ??
      const AppSemanticColors(income: Colors.green, expense: Colors.red);
}
