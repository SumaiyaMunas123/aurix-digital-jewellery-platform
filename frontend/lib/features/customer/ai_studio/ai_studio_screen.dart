import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class AiStudioScreen extends StatelessWidget {
  const AiStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: const [
        AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AI Studio", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              SizedBox(height: 8),
              Text(
                "Later: Generate jewellery designs using prompts + image references.",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}