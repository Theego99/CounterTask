import 'package:flutter/material.dart';
import 'package:counter/stats_screen.dart';
import 'package:counter/bottommenu.dart';
import 'package:counter/Settings/settings_screen.dart';
import 'package:counter/counters/my_counters_screen.dart';
import 'package:counter/counters/data_model.dart';
import 'package:counter/topbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _Screen();
}

class _Screen extends State<Screen> {
  var activeScreen = 'home-screen';
  Locale _locale = const Locale('en', ''); // Default locale

  void switchScreen(String screen, [Locale? newLocale]) {
    if (newLocale != null) {
      setState(() {
        _locale = newLocale; // Update locale if provided
      });
    }
    if (screen != activeScreen) {
      setState(() {
        activeScreen = screen;
      });
    }
  }

  @override
  Widget build(context) {
    return MaterialApp(
      locale: _locale, // Set the locale here
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 77, 31, 201),
        body: Column(
          children: [
            MyAppBar(title: "JiCounter"),
            Expanded(child: _buildScreenWidget()),
            BottomMenu(switchScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenWidget() {
    switch (activeScreen) {
      case 'stats-screen':
        return StatScreen();
      case 'settings-screen':
        return SettingsPage(
            onLocaleChange: (locale) => switchScreen(activeScreen, locale));
      default:
        return MyCounters(dataModel: CounterDataModel());
    }
  }
}
