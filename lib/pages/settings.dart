import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:wenku8/global.dart';
import 'package:wenku8/main.dart';
import 'package:wenku8/widgets/page/stateful_page.dart';
import 'package:wenku8/widgets/setting/single_select_dialog_tile.dart';

final themeOptions = {
  "light": "淺色",
  "dark": "深色",
  "system": "跟隨系統主題",
};

class SettingsPage extends StatefulPage {
  const SettingsPage({super.key});

  @override
  String get pageTitle => "設定";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin {
  String currentTheme = Global.preferences.getString("theme") ?? "system";

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: [
        SingleSelectDialogTile(
          leading: const Icon(Symbols.dark_mode_rounded),
          title: const Text("主題色"),
          settingKey: "theme",
          options: themeOptions,
          initialValue: currentTheme,
          defaultValue: "system",
          onValueChanged: (value) {
            MainApp.of(context)!.changeTheme(value);
          },
        )
      ],
    );
  }
}
