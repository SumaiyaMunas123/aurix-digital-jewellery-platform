import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

import '../models/ai_generation_request.dart';
import '../widgets/generated_image_widget.dart';
import '../widgets/result_action_buttons_widget.dart';

class AiResultScreen extends StatelessWidget {
  final AiGenerationRequest request;

  const AiResultScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
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
                      "Design Generated",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              AurixGlassCard(
                child: SizedBox(
                  height: 220,
                  child: GeneratedImageWidget(request: request),
                ),
              ),
              const SizedBox(height: 20),
              AurixGlassCard(
                child: ResultActionButtonsWidget(request: request),
              ),
            ],
          ),
        ),
      ),
    );
  }
}