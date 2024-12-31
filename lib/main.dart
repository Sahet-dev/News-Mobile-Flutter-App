import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(DailyNewsApp());
}

class DailyNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}