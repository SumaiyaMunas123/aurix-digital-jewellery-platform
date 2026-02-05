import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'terms_conditions_screen.dart';
import 'settings_screen.dart';
import 'about_us_screen.dart';

class SideNavigationScreen extends StatelessWidget {
  const SideNavigationScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => Navigator.pop(context), // Close drawer when tapping outside
      child: Scaffold(
        //backgroundColor: Colors.white.withOpacity(0.5), // Semi-transparent overlay
        body: Row(
          children: [
            // Side Navigation Drawer (3/4 width)
            Container(
              width: screenWidth * 0.75, // 75% of screen width
              color: primaryColor,
              child: SafeArea(
                child: Column(
                  children: [
                    // User Profile Section
                    _buildUserProfile(isDark),
                    const SizedBox(height: 30),
                    
                    // Menu Items
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildMenuItem(
                              context: context,
                              icon: Icons.person_outline,
                              title: 'My Account',
                              onTap: () {
                                Navigator.pop(context); // Close drawer first
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.contact_mail_outlined,
                              title: 'Contact Us',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutUsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.info_outline,
                              title: 'About Us',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutUsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.settings_outlined,
                              title: 'Settings',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TermsConditionsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.arrow_back,
                              title: 'Back',
                              textColor: const Color(0xFF303030),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () => _handleLogout(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Empty space (1/4 width) - tapping here closes the drawer
            Expanded(child: Container(color: Colors.transparent)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Picture Placeholder (no NetworkImage)
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dilakshan',
                  style: TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Verified User',
                  style: TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = const Color(0xFFF5F5F5),
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close side navigation
              Navigator.pushReplacementNamed(context, '/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
