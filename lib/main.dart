import 'package:flutter/material.dart';
import 'package:counter/Screens.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Initialize FFI for not mobile only
  sqfliteFfiInit();
  // Set the database factory for not mobile only
  databaseFactory = databaseFactoryFfi;


  runApp(Screen());  // Pass the dataModel to your main screen
}
