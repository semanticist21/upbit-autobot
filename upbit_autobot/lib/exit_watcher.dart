import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/pages/login.dart';
import 'package:upbit_autobot/provider.dart';
import 'package:window_manager/window_manager.dart';

class ExitWatcher extends StatefulWidget {
  final int processPid;

  const ExitWatcher({super.key, required this.processPid});

  @override
  State<ExitWatcher> createState() => _ExitWatcherState();
}

class _ExitWatcherState extends State<ExitWatcher> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    if (widget.processPid != -1) Process.killPid(widget.processPid);
    super.onWindowClose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        theme: ThemeData.dark(),
        title: '로그인',
        home: const Login(),
      ),
    );
  }
}
