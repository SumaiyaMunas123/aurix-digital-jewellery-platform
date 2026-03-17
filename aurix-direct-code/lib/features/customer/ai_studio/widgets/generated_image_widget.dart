import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aurix/core/theme/app_colors.dart';

import '../models/ai_generation_request.dart';

class GeneratedImageWidget extends StatelessWidget {
  final AiGenerationRequest request;

  const GeneratedImageWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ImagePreview(request: request),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          color: Colors.transparent,
          child: _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (request.isSketchMode && request.sketchPath != null) {
      return Image.file(
        File(request.sketchPath!),
        fit: BoxFit.cover,
      );
    }

    return const Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 60,
        color: AppColors.gold,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final AiGenerationRequest request;

  const _ImagePreview({required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: request.isSketchMode && request.sketchPath != null
                    ? Image.file(File(request.sketchPath!))
                    : const Icon(
                        Icons.auto_awesome_rounded,
                        size: 200,
                        color: AppColors.gold,
                      ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}