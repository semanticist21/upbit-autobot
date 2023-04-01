class SellItem {
  String coinMarketName;
  double avgBuyPrice;
  double executedVolume;
  double profitTargetPrice;
  double lossTargetPrice;

  SellItem(
      {required this.coinMarketName,
      required this.avgBuyPrice,
      required this.executedVolume,
      required this.profitTargetPrice,
      required this.lossTargetPrice});

  factory SellItem.fromJson(Map<String, dynamic> map) {
    return SellItem(
        coinMarketName: map['coinMarketName'],
        avgBuyPrice: map['avgBuyPrice'] is int
            ? (map['avgBuyPrice'] as int).toDouble()
            : map['avgBuyPrice'],
        executedVolume: map['executedVolume'],
        profitTargetPrice: map['profitTargetPrice'],
        lossTargetPrice: map['lossTargetPrice']);
  }
}
