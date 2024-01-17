import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu(this.switchScreen, {super.key});

  final void Function(String) switchScreen;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuItem(Icons.home_filled, AppLocalizations.of(context)!.home, () => switchScreen('home-screen')),
          _buildMenuItem(Icons.analytics, AppLocalizations.of(context)!.insights, () => switchScreen('stats-screen')),
          _buildMenuItem(Icons.settings, AppLocalizations.of(context)!.settings, () => switchScreen('settings-screen')),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 40), 
            Text(label, style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

