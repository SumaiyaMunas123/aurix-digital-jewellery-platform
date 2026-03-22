import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/core/theme/app_colors.dart';

import '../models/ai_generation_request.dart';
import '../pages/quotation_jeweller_select_screen.dart';

class ResultActionButtonsWidget extends StatefulWidget {
  final AiGenerationRequest request;

  const ResultActionButtonsWidget({
    super.key,
    required this.request,
  });

  @override
  State<ResultActionButtonsWidget> createState() =>
      _ResultActionButtonsWidgetState();
}

class _ResultActionButtonsWidgetState
    extends State<ResultActionButtonsWidget> {
  bool _wishlisted = false;
  bool _saving = false;
  bool _sharing = false;

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<bool> _requestSavePermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;

      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    return false;
  }

  Future<void> _saveToPhone() async {
    HapticFeedback.selectionClick();

    if (widget.request.sketchPath == null ||
        widget.request.sketchPath!.isEmpty) {
      _showSnack(
        'No image file available yet. Text-to-image save will work once the backend returns the generated image file.',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final allowed = await _requestSavePermission();
      if (!allowed) {
        _showSnack('Permission denied. Please allow gallery/photos access.');
        return;
      }

      final file = File(widget.request.sketchPath!);
      if (!await file.exists()) {
        _showSnack('Image file not found.');
        return;
      }

      final Uint8List bytes = await file.readAsBytes();
      final fileName =
          'aurix_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await SaverGallery.saveImage(
        bytes,
        fileName: fileName,
        skipIfExists: false,
        androidRelativePath: "Pictures/Aurix",
      );

      _showSnack('Saved to phone.');
    } catch (e) {
      _showSnack('Failed to save image.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareDesign() async {
    HapticFeedback.selectionClick();

    setState(() => _sharing = true);

    try {
      final path = widget.request.sketchPath;

      if (path != null && path.isNotEmpty && await File(path).exists()) {
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Aurix AI Design\n${widget.request.prompt}',
          subject: 'Aurix AI Design',
        );
      } else {
        await Share.share(
          'Aurix AI Design\n${widget.request.prompt}',
          subject: 'Aurix AI Design',
        );
      }
    } catch (_) {
      _showSnack('Failed to open share sheet.');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _getQuotation() {
    HapticFeedback.selectionClick();
    Nav.push(
      context,
      QuotationJewellerSelectScreen(request: widget.request),
    );
  }

  void _toggleWishlist() {
    HapticFeedback.selectionClick();
    setState(() => _wishlisted = !_wishlisted);
    _showSnack(
      _wishlisted ? 'Added to wishlist.' : 'Removed from wishlist.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _button(
                icon: Icons.download_rounded,
                label: _saving ? "Saving..." : "Save to Photos",
                onTap: _saving ? null : _saveToPhone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _button(
                icon: Icons.request_quote_rounded,
                label: "Get Quotation",
                onTap: _getQuotation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _button(
                icon: Icons.share_rounded,
                label: _sharing ? "Sharing..." : "Share Design",
                onTap: _sharing ? null : _shareDesign,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _button(
                icon: _wishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: _wishlisted ? "Wishlisted" : "Add to Wishlist",
                onTap: _toggleWishlist,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.25),
          ),
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: isDark ? 0.05 : 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.gold),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}