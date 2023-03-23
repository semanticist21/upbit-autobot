import 'package:intl/intl.dart';

class Converter {
  static String currencyFormat(int price) {
    final formatCurrency = NumberFormat.simpleCurrency(
        locale: "ko_KR", name: "", decimalDigits: 0);

    return formatCurrency.format(price);
  }

  static String currencyFormatDouble(double price) {
    final formatCurrency = NumberFormat.simpleCurrency(
        locale: "ko_KR", name: "", decimalDigits: 0);

    return formatCurrency.format(price);
  }
}
