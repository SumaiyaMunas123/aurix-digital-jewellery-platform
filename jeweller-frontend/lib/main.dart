import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/jeweller_registration_screen.dart';
import 'screens/pending_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/gold_rate_screen.dart';
import 'screens/ai_design_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_overview_screen.dart';
import 'screens/chat_thread_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/side_navigation_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/ai_text_prompt_screen.dart';
import 'screens/ai_sketch_upload_screen.dart';
import 'screens/ai_my_designs_screen.dart';
import 'screens/ai_design_studio_screen.dart';

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
        '/customer-home': (context) => const HomeScreen(),
        '/jeweller-registration': (context) =>
            const JewellerRegistrationScreen(),
        '/pending-verification': (context) => const PendingVerificationScreen(),
        '/main': (context) => const MainNavigation(),
        '/chat-overview': (context) => const ChatOverviewScreen(),
        '/chat-thread': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(body: SizedBox.shrink());
          }
          return ChatThreadScreen(
            threadId: args['threadId'] ?? '',
            shopName: args['shopName'] ?? '',
            jewellerId: args['jewellerId'] ?? '',
            customerId: args['customerId'] ?? '',
          );
        },
        '/product-detail': (context) => const ProductDetailScreen(),
        '/side-navigation': (context) => const SideNavigationScreen(),
        '/ai-chat': (context) => const AIChatScreen(),
        '/ai-text-prompt': (context) => const AITextPromptScreen(),
        '/ai-sketch-upload': (context) => const AISketchUploadScreen(),
        '/ai-my-designs': (context) => const AIMyDesignsScreen(),
        '/ai-design-studio': (context) => const AIDesignStudioScreen(),
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
          // Floating AI Chat Button
          Positioned(
            right: 16,
            bottom: 144,
            child: FloatingActionButton.small(
              heroTag: 'ai_chat_fab',
              backgroundColor: const Color(0xFF7C3AED),
              onPressed: () {
                Navigator.pushNamed(context, '/ai-chat');
              },
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
          ),
          // Floating Chat Button
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton(
              heroTag: 'chat_fab',
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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
