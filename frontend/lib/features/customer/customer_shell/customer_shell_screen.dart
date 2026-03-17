import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/widgets/aurix_app_bar.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_bottom_nav.dart';
import '../../../core/widgets/aurix_drawer.dart';

import '../ai_studio/ai_studio_screen.dart';
import '../chat/chat_list_screen.dart';
import '../home/customer_home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/customer_search_screen.dart';
import '../wishlist/wishlist_screen.dart';

class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({super.key});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    CustomerSearchScreen(),
    AiStudioScreen(),
    WishlistScreen(),
    ChatListScreen(),
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
                    child: AurixBottomNav(
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