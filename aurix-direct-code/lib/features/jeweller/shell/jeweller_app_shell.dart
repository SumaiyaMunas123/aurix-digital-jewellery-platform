import 'package:flutter/material.dart';
import '../widgets/jeweller_bottom_nav.dart';

class JewellerAppShell extends StatefulWidget {
  const JewellerAppShell({super.key});

  @override
  State<JewellerAppShell> createState() => _JewellerAppShellState();
}

class _JewellerAppShellState extends State<JewellerAppShell> {
  int _index = 0;

  final _pages = const [
    Center(child: Text("Dashboard")),
    Center(child: Text("Products")),
    Center(child: Text("Messages")),
    Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: JewellerBottomNav(
        index: _index,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
      ),
    );
  }
}