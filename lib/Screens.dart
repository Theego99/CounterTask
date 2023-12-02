import 'package:flutter/material.dart';
import 'package:counter/stats_screen.dart';
import 'package:counter/bottommenu.dart';
import 'package:counter/Settings/settings_screen.dart';
import 'package:counter/counters/my_counters_screen.dart';
import 'package:counter/counters/data_model.dart';
import 'package:counter/topbar.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() {
    return _Screen();
  }
}

class _Screen extends State<Screen> {
  var activeScreen = 'home-screen';

  void switchScreen(String screen) {
    setState(
      () {
        activeScreen = screen;
      },
    );
  }

  @override
  Widget build(context) {
    Widget topbar = MyAppBar(title: "JiCounter");
    Widget screenWidget = MyCounters(
      dataModel: CounterDataModel(),
    );
    Widget appBar = BottomMenu(switchScreen);
    if (activeScreen == 'stats-screen') {
      screenWidget = StatScreen();
    } else if (activeScreen == 'settings-screen') {
      screenWidget = const Settings();
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 77, 31, 201),
        body: Column(
          children: [
            topbar,
            Expanded(
              child: screenWidget,
            ),
            appBar,
          ],
        ),
      ),
    );
  }
}
