import 'package:farm/screens/onboarding_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farming App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const OnboardingPage(),
    );
  }
}
