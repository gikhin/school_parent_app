import 'package:flutter/material.dart';
import 'package:untitled25/Homepage.dart';
import 'package:untitled25/Login%20and%20signup/Login.dart';
import 'package:untitled25/Maps/polyline.dart';
import 'package:untitled25/Maps/trackingPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: Loginpage(),
    );
  }
}

