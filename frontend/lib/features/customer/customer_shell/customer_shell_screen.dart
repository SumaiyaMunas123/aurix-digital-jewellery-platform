import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurix/core/widgets/aurix_app_bar.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_bottom_nav.dart';
import 'package:aurix/core/widgets/aurix_drawer.dart';

import 'package:aurix/features/customer/home/customer_home_screen.dart';
import 'package:aurix/features/customer/search/customer_search_screen.dart';
import 'package:aurix/features/customer/ai_studio/ai_studio_screen.dart';
import 'package:aurix/features/customer/chat/chat_list_screen.dart';
import 'package:aurix/features/customer/wishlist/wishlist_screen.dart';

class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({super.key});

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  int _index = 0;

  final _pages = const [
    CustomerHomeScreen(),
    CustomerSearchScreen(),
    AiStudioScreen(),
    ChatListScreen(),
    WishlistScreen(),
  ];

  void _setIndex(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AurixDrawer(),
      extendBody: true, // ✅ lets content show behind glass nav
      body: AurixBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  AurixAppBar(
                    title: "Aurix",
                    onMenu: () => Scaffold.of(context).openDrawer(),
                    onBell: () {},
                  ),
                  Expanded(
                    child: IndexedStack(index: _index, children: _pages),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AurixBottomNav(index: _index, onChanged: _setIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}