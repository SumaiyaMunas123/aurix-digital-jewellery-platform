import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/theme/app_colors.dart';

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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AiResultScreen(request: widget.request),
        ),
      );
    });
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
                color: Colors.black.withOpacity(0.15),
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