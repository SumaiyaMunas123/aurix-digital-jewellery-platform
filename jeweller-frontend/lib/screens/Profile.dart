import 'package:flutter/material.dart';

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
        primaryColor: const Color(0xFFD4AF35),
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
        fontFamily: 'Manrope',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF35),
        scaffoldBackgroundColor: const Color(0xFF201D12),
        fontFamily: 'Manrope',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 4; // Default to Account

  final List<Widget> _screens = const [
    Center(child: Text("Home Screen", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    Center(child: Text("Search Screen", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    Center(child: Text("Gold Rate Screen", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    Center(child: Text("AI Design Screen", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF35),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Gold Rate'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Design'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

/* ========================
   PROFILE SCREEN
   ======================== */
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final String userName = "Dilakshan";
  final String userStatus = "Verified User";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF201D12) : Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFD4AF35),
                child: Text(
                  userName[0],
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userStatus,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Menu Options
          ProfileOption(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () {},
          ),
          ProfileOption(
            icon: Icons.lock,
            title: 'Password',
            onTap: () {},
          ),
          ProfileOption(
            icon: Icons.notifications,
            title: 'Notification',
            onTap: () {},
          ),
          ProfileOption(
            icon: Icons.info,
            title: 'About',
            onTap: () {},
          ),
          ProfileOption(
            icon: Icons.help,
            title: 'FAQ / Help',
            onTap: () {},
          ),
          ProfileOption(
            icon: Icons.delete_forever,
            title: 'Deactivate my account',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Deactivate Account'),
                  content: const Text(
                      'Are you sure you want to deactivate your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Account deactivated successfully')),
                        );
                      },
                      child: const Text(
                        'Deactivate',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ========================
   PROFILE OPTION WIDGET
   ======================== */
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF35), width: 0.8),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFFD4AF35)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}