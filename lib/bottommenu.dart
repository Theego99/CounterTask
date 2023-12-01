import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu(this.switchScreen, {super.key});

  final void Function(String) switchScreen;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0,0, 0, 8),
          child: Row(
            // Set crossAxisAlignment to center to align icons vertically in the middle.
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                color: Colors.white,
                onPressed: () {
                  switchScreen('home-screen');
                },
                icon: const Icon(Icons.home_filled),
                tooltip: "My counters",
              ),
                IconButton(
                color: Colors.white,
                onPressed: () {
                  switchScreen('stats-screen');
                },
                icon: const Icon(Icons.analytics),
                tooltip: "Statistics",
              ),
              IconButton(
                color: Colors.white,
                onPressed: () {
                  switchScreen('settings-screen');
                },
                icon: const Icon(Icons.settings),
                tooltip: "Settings",
              ),
              // Add more IconButton widgets as needed
            ],
          ),
        ),
      ),
    );
  }
}

