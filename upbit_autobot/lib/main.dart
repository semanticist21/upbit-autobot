import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';
import 'package:upbit_autobot/pages/login.dart';
import 'package:upbit_autobot/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.setSize(const Size(800, 600));
    windowManager.setMinimumSize(const Size(800, 600));
    windowManager.setMaximumSize(const Size(1024, 768));
    windowManager.setResizable(false);
  }

  await Window.initialize();
  await Window.setEffect(
      effect: WindowEffect.acrylic, color: const Color.fromARGB(50, 0, 0, 0));

  FlutterError.onError =
      (FlutterErrorDetails details) => FlutterError.presentError(details);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
