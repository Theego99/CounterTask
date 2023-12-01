import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            'assets/images/Blacklogonobackground.png',
            width: 200,
            color: const Color.fromARGB(149, 255, 255, 255),
          ),
          const SizedBox(height: 100),
          Text(
            'Keep track of every task!',
            style: GoogleFonts.lato(
              color: const Color.fromARGB(255, 237, 223, 252),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_box),
            label: Text(
              'New counter group',
              style: GoogleFonts.lato(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
