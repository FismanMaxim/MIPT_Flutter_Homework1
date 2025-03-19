import 'package:flutter/material.dart';
import 'package:tinder_cats/screens/main_screen.dart';

void main() {
  runApp(CatTinderApp());
}

class CatTinderApp extends StatelessWidget {
  const CatTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Tinder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}
