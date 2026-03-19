import 'dart:ui';
import 'package:flutter/material.dart';

class AurixAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenu;
  final VoidCallback? onBell;
  final String title;

  const AurixAppBar({
    super.key,
    required this.title,
    this.onMenu,
    this.onBell,
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            _glassIcon(context, icon: Icons.menu_rounded, onTap: onMenu),
            const Spacer(),
            _glassTitle(context, title),
            const Spacer(),
            _glassIcon(context,
                icon: Icons.notifications_none_rounded, onTap: onBell),
          ],
        ),
      ),
    );
  }

  Widget _glassTitle(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: isDark ? 0.06 : 0.04),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _glassIcon(BuildContext context,
      {required IconData icon, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: isDark ? 0.06 : 0.04),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
                ),
              ),
              child: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}