import 'package:flutter/material.dart';
import 'dart:async';
import 'news_feed_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
      // Navigate to NewsFeedScreen after 3 seconds
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewsFeedScreen()),
        );
      });

      return Scaffold(
      backgroundColor: const Color(0xFF4f86f7),
      body: Center(
        child: Text(
          'Daily News',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}