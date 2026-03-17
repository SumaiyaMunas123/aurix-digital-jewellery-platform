import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AurixBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const AurixBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: (isDark ? Colors.white : Colors.black)
                    .withOpacity(isDark ? 0.07 : 0.05),
                border: Border.all(
                  color:
                      (isDark ? Colors.white : Colors.black).withOpacity(0.10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _item(context, 0, Icons.home_rounded),
                  _item(context, 1, Icons.search_rounded),
                  _item(context, 2, Icons.auto_awesome_rounded),
                  _item(context, 3, Icons.chat_bubble_rounded),
                  _item(context, 4, Icons.favorite_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon) {
    final selected = index == i;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => onChanged(i),
        radius: 28,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: selected ? 54 : 44,
          height: selected ? 54 : 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? (isDark
                    ? AppColors.gold.withOpacity(0.20)
                    : AppColors.gold.withOpacity(0.18))
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 24,
            color: selected ? AppColors.gold : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}