import 'package:counter/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:counter/Screens.dart';

class SettingsPage extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  SettingsPage({required this.onLocaleChange});
  @override
  Widget build(BuildContext context) {
    final languages = {
      'English': Locale('en', ''),
      'Español': Locale('es', ''),
      '日本語': Locale('ja', ''),
      '中文': Locale('zh', ''),
    };

    return Scaffold(
      body: ListView(
        children: languages.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            onTap: () {
              onLocaleChange(
                  entry.value);
            },
          );
        }).toList(),
      ),
    );
  }
}
