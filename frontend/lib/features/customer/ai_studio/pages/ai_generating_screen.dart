import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/theme/app_colors.dart';

import '../data/ai_repository.dart';
import '../models/ai_generation_request.dart';
import 'ai_result_screen.dart';

class AiGeneratingScreen extends StatefulWidget {
  final AiGenerationRequest request;

  const AiGeneratingScreen({super.key, required this.request});

  @override
  State<AiGeneratingScreen> createState() => _AiGeneratingScreenState();
}

class _AiGeneratingScreenState extends State<AiGeneratingScreen>
    with SingleTickerProviderStateMixin {
  // Pulse animation controller
  late final AnimationController _controller;
  // AI image generation API
  final _aiRepository = AiRepository();
  // Error message if generation fails
  String? _error;

  @override
  void initState() {
    super.initState();

    // Setup pulsing animation (scales between 0.8 and 1.25)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.8,
      upperBound: 1.25,
    )..repeat(reverse: true);

    // Start image generation immediately
    _generateImage();
  }

  // Call API to generate image, then navigate or show error
  Future<void> _generateImage() async {
    try {
      print('🎈 Starting AI image generation...');
      
      // Send generation request to backend
      final result = await _aiRepository.generateImage(
        request: widget.request,
        mode: widget.request.mode,
      );

      if (!mounted) return;

      // Extract image URLs from response
      final imageUrl = (result['imageUrl'] ?? '').toString();
      final imageBase64 = (result['imageBase64'] ?? '').toString();
      
      print('✅ Image generated successfully: $imageUrl');

      // Prepare updated request with generated image
      final updatedRequest = widget.request.copyWith(
        imageUrl: imageUrl,
        imageBase64: imageBase64,
      );

      // Navigate to result screen (with image preview)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AiResultScreen(request: updatedRequest),
        ),
      );
    } catch (e) {
      print('❌ Generation failed: $e');
      if (!mounted) return;
      
      // Show error state
      setState(() => _error = e.toString());

      // Display error for 3 seconds, then pop back
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    // Clean up animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state with pulsing animation or error message
    return Scaffold(
      body: AurixBackground(
        child: Stack(
          children: [
            // Blurred backdrop
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
            // Center content: error or loading spinner
            Center(
              child: _error != null
                  // Show error message if generation failed
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _error ?? 'Generation failed',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  // Show pulsing animation while generating
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) {
                        return Transform.scale(
                          scale: _controller.value,
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 80,
                            color: AppColors.gold,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
