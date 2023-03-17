import 'package:flutter/material.dart';

class CoinImage extends StatelessWidget {
  const CoinImage({super.key, required this.coinNm});

  final String coinNm;
  final String iconUrl = 'https://coinicons-api.vercel.app/api/icon/';

  @override
  Widget build(BuildContext context) {
    return Image.network(
      iconUrl + coinNm,
      fit: BoxFit.contain,
    );
  }
}
