import 'package:app_scope/views/chatScreen/chat.dart';
import 'package:app_scope/views/chatScreen/connection.dart';
import 'package:app_scope/views/homeScreen/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home:HomeScreen(),
    );
  }
}
