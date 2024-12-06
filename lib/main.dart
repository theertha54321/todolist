import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';
import 'package:todolist/view/home_screen/home_screen.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await TodolistScreenController.initializeDatabase();

 
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}