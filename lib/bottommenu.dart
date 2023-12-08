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
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 2), // Reduced bottom padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox( // Wrap with FittedBox
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        switchScreen('home-screen');
                      },
                      icon: const Icon(Icons.home_filled),
                      tooltip: "My counters",
                    ),
                    Text('Home', style: TextStyle(color: Colors.white, fontSize: 10)), // Reduced font size
                  ],
                ),
              ),
              FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        switchScreen('stats-screen');
                      },
                      icon: const Icon(Icons.analytics),
                      tooltip: "Statistics",
                    ),
                    Text('Insights', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
              FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: () {
                        switchScreen('settings-screen');
                      },
                      icon: const Icon(Icons.settings),
                      tooltip: "Settings",
                    ),
                    Text('Settings', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
              // Add more Column widgets with IconButton and Text as needed
            ],
          ),
        ),
      ),
    );
  }
}
