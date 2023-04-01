import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class CustomConverter {
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

  static String generateRandomString() {
    var random = Random();
    var randomBytes = List.generate(32, (index) => random.nextInt(256));
    var digest = sha256.convert(randomBytes);

    return digest.toString();
  }
}
