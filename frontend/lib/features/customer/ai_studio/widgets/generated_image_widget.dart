import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aurix/core/theme/app_colors.dart';

class GeneratedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? imageBase64;
  final String? sketchPath;

  const GeneratedImageWidget({
    super.key,
    this.imageUrl,
    this.imageBase64,
    this.sketchPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ImagePreview(
              imageUrl: imageUrl,
              imageBase64: imageBase64,
              sketchPath: sketchPath,
            ),
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
    // Show generated image from backend
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.gold,
          ),
        ),
      );
    }

    // Show local sketch if in sketch mode
    if (sketchPath != null && sketchPath!.isNotEmpty) {
      return Image.file(
        File(sketchPath!),
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
  final String? imageUrl;
  final String? imageBase64;
  final String? sketchPath;

  const _ImagePreview({
    this.imageUrl,
    this.imageBase64,
    this.sketchPath,
  });

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
                child: _buildImage(),
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

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.error_outline,
          size: 200,
          color: AppColors.gold,
        ),
      );
    }

    if (sketchPath != null && sketchPath!.isNotEmpty) {
      return Image.file(File(sketchPath!));
    }

    return const Icon(
      Icons.auto_awesome_rounded,
      size: 200,
      color: AppColors.gold,
    );
  }
}