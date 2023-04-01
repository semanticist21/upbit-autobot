import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';

class AppTrayManager {
  AppTrayManager._init();

  static final AppTrayManager _instance = AppTrayManager._init();
  late final AppWindow appWindow;
  late final SystemTray systemTray;

  factory AppTrayManager() {
    return _instance;
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';

    appWindow = AppWindow();
    systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "autobot",
      iconPath: path,
    );

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: '종료',
        image: Platform.isWindows ? 'assets/exit.bmp' : 'assets/exit.png',
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
}
