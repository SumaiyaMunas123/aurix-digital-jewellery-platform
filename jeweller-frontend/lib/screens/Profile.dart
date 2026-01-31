import 'package:flutter/material.dart';

void main() {
  runApp(const AurixProfileApp());
}

class AurixProfileApp extends StatelessWidget {
  const AurixProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurix App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

/* ========================
   MAIN SCREEN WITH BOTTOM NAV
   ======================== */
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 4; // Default: Account tab

  final List<Widget> _screens = const [
    Center(child: Text("Home Screen", style: TextStyle(fontSize: 20))),
    Center(child: Text("Search Screen", style: TextStyle(fontSize: 20))),
    Center(child: Text("Gold Rate Screen", style: TextStyle(fontSize: 20))),
    Center(child: Text("AI Design Screen", style: TextStyle(fontSize: 20))),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Gold Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'AI Design',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
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
                backgroundColor: const Color(0xFFD4AF37),
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
                      color: Colors.grey.shade600,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFFD4AF37)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor ?? Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
