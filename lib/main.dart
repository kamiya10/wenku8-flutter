import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:wenku/global.dart';
import 'package:wenku/pages/favorites.dart';
import 'package:wenku/pages/recent.dart';
import 'package:wenku/pages/settings.dart';
import 'package:wenku/pages/trending.dart';
import 'package:wenku/widgets/page/stateful_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();

  static MainAppState? of(BuildContext context) => context.findAncestorStateOfType<MainAppState>();
}

class MainAppState extends State<MainApp> {
  final GlobalKey _scaffoldKey = GlobalKey();
  ScaffoldState get scaffold => _scaffoldKey.currentState as ScaffoldState;

  List<StatefulPage> pages = const [
    RecentPage(),
    TrendingPage(),
    FavoritesPage(),
    SettingsPage(),
  ];
  int currentView = 0;
  final PageController _pageController = PageController();

  ThemeMode _themeMode = {
        "light": ThemeMode.light,
        "dark": ThemeMode.dark,
        "system": ThemeMode.system
      }[Global.preferences.getString('theme')] ??
      ThemeMode.system;

  void changeTheme(String themeMode) {
    setState(() {
      switch (themeMode) {
        case "light":
          _themeMode = ThemeMode.light;
          break;
        case "dark":
          _themeMode = ThemeMode.dark;
          break;
        case "system":
          _themeMode = ThemeMode.system;
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: ThemeData(colorScheme: lightDynamic),
          darkTheme: ThemeData(colorScheme: darkDynamic),
          themeMode: _themeMode,
          home: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(pages[currentView].pageTitle),
            ),
            drawer: NavigationDrawer(
              selectedIndex: currentView,
              onDestinationSelected: (value) {
                setState(() {
                  currentView = value;
                });
                scaffold.closeDrawer();
                _pageController.jumpToPage(value);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Image.network("https://i.imgur.com/NMWr6JK.jpg"),
                  ),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Symbols.info_rounded),
                  selectedIcon: Icon(
                    Symbols.info_rounded,
                    fill: 1,
                  ),
                  label: Text("最近更新"),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Symbols.local_fire_department_rounded),
                  selectedIcon: Icon(
                    Symbols.local_fire_department_rounded,
                    fill: 1,
                  ),
                  label: Text("排行榜"),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Symbols.star_rounded),
                  selectedIcon: Icon(
                    Symbols.star_rounded,
                    fill: 1,
                  ),
                  label: Text("我的收藏"),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Symbols.settings_rounded),
                  selectedIcon: Icon(
                    Symbols.settings_rounded,
                    fill: 1,
                  ),
                  label: Text("設定"),
                ),
              ],
            ),
            body: SafeArea(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
          ),
        );
      },
    );
  }
}
