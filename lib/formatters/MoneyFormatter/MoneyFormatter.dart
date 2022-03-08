import 'package:afarma/formatters/MoneyFormatter/money_formatter_settings.dart';

import 'flutter_money_formatter_base.dart';

class MoneyFormatter {
  static String format(double input) {
    if (input == null) return format(0.0);
    return FlutterMoneyFormatter(
            amount: double.parse(input.toStringAsFixed(2)),
            settings: MoneyFormatterSettings(
                decimalSeparator: ',', symbol: 'R\$', thousandSeparator: '.'))
        .output
        .symbolOnLeft
        .replaceAll(' ', '');
  }

  static String noSymbolFormat(double input) {
    if (input == null) return noSymbolFormat(0.0);
    return FlutterMoneyFormatter(
            amount: double.parse(input.toStringAsFixed(2)),
            settings: MoneyFormatterSettings(
                decimalSeparator: ',', symbol: '', thousandSeparator: '.'))
        .output
        .symbolOnLeft;
  }
}
