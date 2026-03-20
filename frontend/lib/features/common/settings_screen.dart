import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aurix/core/theme/theme_controller.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(theme.currentIcon),
                      title: const Text('App Theme'),
                      subtitle: Text('Current: ${theme.currentLabel}'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _themeButton(
                            label: 'System',
                            selected: theme.isSystem,
                            onTap: () => theme.setThemeMode(ThemeMode.system),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _themeButton(
                            label: 'Light',
                            selected: theme.isLight,
                            onTap: () => theme.setThemeMode(ThemeMode.light),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _themeButton(
                            label: 'Dark',
                            selected: theme.isDark,
                            onTap: () => theme.setThemeMode(ThemeMode.dark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Push Notifications'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Language'),
                      subtitle: Text(_language),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) =>
                            setState(() => _language = value),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'English', child: Text('English')),
                          PopupMenuItem(
                              value: 'Sinhala', child: Text('Sinhala')),
                          PopupMenuItem(value: 'Tamil', child: Text('Tamil')),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Privacy'),
                      subtitle: const Text(
                          'Manage privacy options (frontend scaffold)'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Privacy options coming next.')),
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
    );
  }

  Widget _themeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
          border: Border.all(color: const Color(0xFFD4AF37)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: selected ? Colors.black : null,
            ),
          ),
        ),
      ),
    );
  }
}
