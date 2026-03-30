import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

import '../models/ai_generation_request.dart';
import '../widgets/generated_image_widget.dart';
import '../widgets/result_action_buttons_widget.dart';

class AiResultScreen extends StatelessWidget {
  // Contains the original prompt, parameters, and now the generated imageUrl/imageBase64
  final AiGenerationRequest request;

  const AiResultScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // The screen displaying the final generated jewelry design along with action buttons
    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              // Custom Top App Bar with back button
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
                  const SizedBox(width: 40), // Balances the back button for centering
                ],
              ),
              const SizedBox(height: 20),
              
              // Top Section: The Display of the locally generated or remote image
              AurixGlassCard(
                child: SizedBox(
                  height: 220,
                  // Widget that safely renders the AI Image, falling back to base64 if URL is missing
                  child: GeneratedImageWidget(
                    imageUrl: request.imageUrl,
                    imageBase64: request.imageBase64,
                    sketchPath: request.sketchPath,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Lower Section: Buttons to proceed (e.g., Get Quotation, Download, etc.)
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