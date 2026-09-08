import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupeeFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _rupeeFormat.format(amount);
  }
}
