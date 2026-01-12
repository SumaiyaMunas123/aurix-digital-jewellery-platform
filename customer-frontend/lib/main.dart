import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const AurixApp());

class AurixApp extends StatelessWidget {
  const AurixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
