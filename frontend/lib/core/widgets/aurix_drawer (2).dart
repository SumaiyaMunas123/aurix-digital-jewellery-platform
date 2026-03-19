import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_controller.dart';
import '../widgets/aurix_background.dart';
import '../widgets/aurix_glass_card.dart';

import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/features/common/profile_screen.dart';
import 'package:aurix/features/common/settings_screen.dart';
import 'package:aurix/features/common/about_screen.dart';
import 'package:aurix/features/common/terms_screen.dart';
import 'package:aurix/features/auth/presentation/login_screen.dart';

class AurixDrawer extends StatelessWidget {
  const AurixDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AurixBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              children: [
                AurixGlassCard(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _themeToggleButton(
                        isDarkNow: isDarkNow,
                        onTap: () {
                          if (isDarkNow) {
                            theme.setThemeMode(ThemeMode.light);
                          } else {
                            theme.setThemeMode(ThemeMode.dark);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _menuTile(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: "Profile",
                        onTap: () => Nav.push(context, const ProfileScreen()),
                      ),
                      _menuTile(
                        context,
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () => Nav.push(context, const SettingsScreen()),
                      ),
                      _menuTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: "About",
                        onTap: () => Nav.push(context, const AboutScreen()),
                      ),
                      _menuTile(
                        context,
                        icon: Icons.description_outlined,
                        title: "Terms & Conditions",
                        onTap: () => Nav.push(context, const TermsScreen()),
                      ),
                      _menuTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeToggleButton({
    required bool isDarkNow,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFD4AF37).withOpacity(0.9),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.35),
          ),
        ),
        child: Icon(
          isDarkNow ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AurixGlassCard(
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}