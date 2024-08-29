import 'package:ble_chat_app/Pages/chat_page.dart';
import 'package:ble_chat_app/Pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

void main() => runApp(
      const MyApp(),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Chat App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.purple,
        ),
        primarySwatch: Colors.purple,
      ),
      home: const SplashScreen(),
    );
  }
}
