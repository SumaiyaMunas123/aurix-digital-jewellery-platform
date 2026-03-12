import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AurixDrawer extends StatelessWidget {
  const AurixDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: const [
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text("Profile"),
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text("Settings"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
            ),
          ],
        ),
      ),
    );
  }
}