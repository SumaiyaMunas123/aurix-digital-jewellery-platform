import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/gold_rate_screen.dart';
import 'screens/ai_design_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_overview_screen.dart';
import 'screens/chat_thread_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/side_navigation_screen.dart';

void main() {
  runApp(const AurixApp());
}

class AurixApp extends StatelessWidget {
  const AurixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurix',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
        fontFamily: 'Manrope',
        primaryColor: const Color(0xFFD4AF35),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF201D12),
        fontFamily: 'Manrope',
        primaryColor: const Color(0xFFD4AF35),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainNavigation(),
        '/chat-overview': (context) => const ChatOverviewScreen(),
        '/chat-thread': (context) => const ChatThreadScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/side-navigation': (context) => const SideNavigationScreen(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    GoldRateScreen(),
    AIDesignScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Floating Chat Button
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFD4AF35),
              onPressed: () {
                Navigator.pushNamed(context, '/chat-overview');
              },
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF35),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Gold Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI Design',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
