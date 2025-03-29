import 'package:flutter/material.dart';
import 'package:tinder_cats/di/locator.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  setupLocator();
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
