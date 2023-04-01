import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoinImage extends StatelessWidget {
  const CoinImage({super.key, required this.coinNm});

  final String coinNm;
  final String iconUrl = 'https://cryptoicons.org/api/icon/';
  final String suffix = '/400';

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      filterQuality: FilterQuality.high,
      imageUrl: '$iconUrl$coinNm$suffix',
      placeholder: (context, url) => new CircularProgressIndicator(),
      errorWidget: (context, url, error) => new Image.asset(
          'lib/assets/coin.png',
          filterQuality: FilterQuality.high,
          isAntiAlias: true),
    );
  }
}

//attribution https://pngtree.com/freepng/blank-gold-coins-transparent_6084926.html
