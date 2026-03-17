import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText = "See all",
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const Spacer(),
        if (onAction != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onAction!.call();
            },
            child: Text(
              actionText,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}