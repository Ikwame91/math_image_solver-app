import 'package:flutter/material.dart';
import 'package:math_image_solver/ui/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GemeniMaths',
        theme: ThemeData(),
        home: const HomePage());
  }
}
