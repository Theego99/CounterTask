import 'package:flutter/material.dart';

Widget customProxyDecorator(
    Widget child, int index, Animation<double> animation) {
  return Material(
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 77, 31, 201),
        ),

      child: Transform.scale(
          // e.g: vertical negative margin
          scaleY: 1.05,
          scaleX: 1.05,
          child: child),
    ),);
}
