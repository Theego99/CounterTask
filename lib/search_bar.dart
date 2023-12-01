import 'package:flutter/material.dart';

//searchbar
class MySearchBar extends StatelessWidget {
  final String hintText;

  const MySearchBar({required this.hintText, super.key});

  @override
  Widget build(BuildContext context) {
    double searchBarWidth =
        MediaQuery.of(context).size.width * 0.6; // 80% of the screen width

    return Center(
      child: SizedBox(
        width: searchBarWidth,
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color.fromRGBO(
                  121, 241, 247, 1), // Set your desired hint text color
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white, // Set your desired icon color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                color: Colors.white, // Set your desired border color
                width: 2.0, // Set the border width
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                color: Color.fromRGBO(121, 241, 247,
                    1), // Set your desired border color when focused
                width: 2.0, // Set the border width when focused
              ),
              
            ),
          ),
          style: const TextStyle(
            color: Colors.white, // Set the text color inside the TextField
          ),
        ),
      ),
    );
  }
}
