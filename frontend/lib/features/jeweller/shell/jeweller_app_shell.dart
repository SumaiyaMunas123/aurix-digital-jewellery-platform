import 'package:flutter/material.dart';

class JewellerAppShell extends StatelessWidget {
  const JewellerAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Jeweller App Shell\n(We’ll build this later)",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}