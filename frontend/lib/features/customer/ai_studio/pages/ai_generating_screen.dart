import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/core/network/api_client.dart';

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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.8,
      upperBound: 1.25,
    )..repeat(reverse: true);

    _callGenerateApi();
  }

  void _callGenerateApi() async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/ai/generate',
        data: {
          'mode': widget.request.mode,
          'prompt': widget.request.prompt,
          'category': widget.request.category,
          'material': widget.request.material,
          'karat': widget.request.karat,
          'style': widget.request.style,
          'occasion': widget.request.occasion,
          'budget': widget.request.budget,
          'user_type': 'customer',
        },
        options: Options(sendTimeout: const Duration(seconds: 120), receiveTimeout: const Duration(seconds: 120)),
      );

      if (!mounted) return;

      final imageUrl = response.data['data']['image_url'] ?? '';
      final imageBase64 = response.data['data']['image_base64'] ?? '';

      final updatedRequest = widget.request.copyWith(
        imageUrl: imageUrl,
        imageBase64: imageBase64,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AiResultScreen(request: updatedRequest),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating design: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AurixBackground(
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),
            Center(
              child: AnimatedBuilder(
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