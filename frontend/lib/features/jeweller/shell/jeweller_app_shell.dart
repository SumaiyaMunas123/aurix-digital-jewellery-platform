import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/widgets/aurix_app_bar.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_drawer.dart';
import '../../customer/chat/chat_list_screen.dart';
import '../../customer/notifications/notifications_screen.dart';

import '../dashboard/jeweller_dashboard_screen.dart';
import '../products/jeweller_products_screen.dart';
import '../profile/jeweller_profile_screen.dart';
import '../widgets/jeweller_bottom_nav.dart';

class JewellerAppShell extends StatefulWidget {
  const JewellerAppShell({super.key});

  @override
  State<JewellerAppShell> createState() => _JewellerAppShellState();
}

class _JewellerAppShellState extends State<JewellerAppShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    JewellerDashboardScreen(),
    JewellerProductsScreen(),
    ChatListScreen(),
    JewellerProfileScreen(),
  ];

  void _setIndex(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  void _openNotifications() {
    HapticFeedback.selectionClick();
    Nav.push(context, const NotificationsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AurixDrawer(),
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Builder(
        builder: (scaffoldContext) {
          return AurixBackground(
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      AurixAppBar(
                        title: 'Aurix',
                        onMenu: () {
                          HapticFeedback.selectionClick();
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                        onBell: _openNotifications,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _index,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: JewellerBottomNav(
                      index: _index,
                      onChanged: _setIndex,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}