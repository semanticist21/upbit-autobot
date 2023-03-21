class CoinBalance {
  final String coinName;
  final String avgBuyPrice;
  final String balance;

  factory CoinBalance.fromJson(Map<String, dynamic> json) {
    return CoinBalance(
        coinName: json['coinName'],
        avgBuyPrice: json['avgBuyPrice'],
        balance: json['balance']);
  }

  CoinBalance(
      {required this.coinName,
      required this.avgBuyPrice,
      required this.balance});
}
