import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AppBar(
        centerTitle: true, // Center the title text horizontally
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children horizontally
          children: [
            Image.asset(
              'assets/images/Whitelogonobackground.png',
              width: 40,
            ),
            Center(
              child: Text(
                title,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            // You can add more widgets here
          ],
        ),
        backgroundColor: Colors.blue,
        toolbarHeight: 40, // Adjust the height as needed
      ),
    );
  }
}
