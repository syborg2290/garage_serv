import 'package:flutter/material.dart';
import 'package:garage/initials/intro.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage',
      debugShowCheckedModeBanner: false, //remove debug banner
      theme: ThemeData(
        primaryColor: Color(0xffFF1744),

        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Intro(),
    );
  }
}
