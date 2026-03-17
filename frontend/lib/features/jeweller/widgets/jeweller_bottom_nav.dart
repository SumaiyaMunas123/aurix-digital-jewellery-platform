import 'package:flutter/material.dart';

class JewellerBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const JewellerBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onTap,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '',
        ),
      ],
    );
  }
}