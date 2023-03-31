import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_tray/system_tray.dart';
import 'package:upbit_autobot/client/client.dart';
import 'package:window_manager/window_manager.dart';

import 'exit_watcher.dart';

void main() async {
  var result = await Process.run('tasklist', []);
  var str = result.stdout.toString().replaceFirst('upbit_autobot', '');
  if (str.contains('upbit_autobot')) {
    exit(0);
  }

  WidgetsFlutterBinding.ensureInitialized();
  RestApiClient().initclient();
  var processPid = -1;

  try {
    var process = await Process.start('upbit-client-server.exe', [],
        mode: ProcessStartMode.detached);
    processPid = process.pid;
  } catch (_) {}

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

  runApp(MainApp(processPid: processPid));
  initSystemTray();
}

class MainApp extends StatelessWidget {
  final int processPid;

  const MainApp({super.key, required this.processPid});

  @override
  Widget build(BuildContext context) {
    return ExitWatcher(processPid: processPid);
  }
}

Future<void> initSystemTray() async {
  String path =
      Platform.isWindows ? 'lib/assets/icon.ico' : 'lib/assets/icon.png';

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    title: "autobot",
    iconPath: path,
  );

  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: '종료',
      image: Platform.isWindows ? 'lib/assets/exit.bmp' : 'lib/assets/exit.png',
      onClicked: (menuItem) {
        appWindow.close();
      },
    ),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    }
  });
}
