import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class Wave extends StatefulWidget {
  const Wave({super.key});

  @override
  State<Wave> createState() => _WaveState();
}

class _WaveState extends State<Wave> {
  static const _backgroundColor = const Color.fromRGBO(59, 130, 246, 0.8);

  static const _colors = [
    Color.fromRGBO(179, 207, 239, 0.5),
    Color.fromRGBO(179, 207, 239, 0.6)
  ];

  static const _durations = [
    5000,
    4000,
  ];

  static const _heightPercentages = [
    0.65,
    0.66,
  ];

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        colors: _colors,
        durations: _durations,
        heightPercentages: _heightPercentages,
      ),
      backgroundColor: _backgroundColor,
      size: const Size(double.maxFinite, double.maxFinite),
      waveAmplitude: 0,
    );
  }
}
