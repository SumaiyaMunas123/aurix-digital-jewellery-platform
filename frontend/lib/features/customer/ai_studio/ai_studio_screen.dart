import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

import 'models/ai_generation_request.dart';
import 'pages/ai_generating_screen.dart';

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final _promptController = TextEditingController();
  final _picker = ImagePicker();

  int _mode = 0; // 0 = Text to Image, 1 = Sketch to Image

  String _category = 'Ring';
  String _weight = '2g - 5g';
  String _material = 'Gold';
  String _karat = '22K';
  String _style = 'Minimal';
  String _occasion = 'Daily Wear';
  String _budget = 'LKR 50,000 - 150,000';

  XFile? _sketchFile;

  final List<String> _categories = const [
    'Ring',
    'Necklace',
    'Pendant',
    'Bangle',
    'Bracelet',
    'Earrings',
    'Chain',
    'Anklet',
  ];

  final List<String> _weights = const [
    'Below 2g',
    '2g - 5g',
    '5g - 10g',
    '10g - 20g',
    '20g+',
  ];

  final List<String> _materials = const [
    'Gold',
    'White Gold',
    'Rose Gold',
    'Silver',
    'Platinum',
  ];

  final List<String> _karats = const [
    '18K',
    '20K',
    '22K',
    '24K',
  ];

  final List<String> _styles = const [
    'Minimal',
    'Luxury',
    'Traditional',
    'Modern',
    'Vintage',
    'Floral',
    'Bridal',
  ];

  final List<String> _occasions = const [
    'Daily Wear',
    'Wedding',
    'Engagement',
    'Gift',
    'Party',
    'Festival',
  ];

  final List<String> _budgets = const [
    'Below LKR 50,000',
    'LKR 50,000 - 150,000',
    'LKR 150,000 - 300,000',
    'LKR 300,000 - 500,000',
    'Above LKR 500,000',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickSketch() async {
    HapticFeedback.selectionClick();

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _sketchFile = picked;
      });
    } catch (_) {
      _showSnack('Failed to pick sketch image.');
    }
  }

  void _startGeneration() {
    final prompt = _promptController.text.trim();

    if (_mode == 0 && prompt.isEmpty) {
      _showSnack('Please enter a prompt first.');
      return;
    }

    if (_mode == 1 && _sketchFile == null) {
      _showSnack('Please upload a sketch first.');
      return;
    }

    HapticFeedback.mediumImpact();

    final request = AiGenerationRequest(
      mode: _mode,
      prompt: _mode == 0 ? prompt : '',
      category: _category,
      weight: _weight,
      material: _material,
      karat: _karat,
      style: _style,
      occasion: _occasion,
      budget: _budget,
      sketchPath: _sketchFile?.path,
    );

    Nav.push(
      context,
      AiGeneratingScreen(request: request),
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text(
          'AI Studio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create jewellery concepts with AI using text prompts or sketches.',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        _modeSwitcher(),
        const SizedBox(height: 16),

        if (_mode == 1) ...[
          _sketchUploader(),
          const SizedBox(height: 16),
        ],

        if (_mode == 0) ...[
          _promptSection(),
          const SizedBox(height: 16),
        ],

        _selectionGrid(),
        const SizedBox(height: 16),

        _generateButton(),
      ],
    );
  }

  Widget _modeSwitcher() {
    return AurixGlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              label: 'Text to Image',
              selected: _mode == 0,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _mode = 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _modeButton(
              label: 'Sketch to Image',
              selected: _mode == 1,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _mode = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? AppColors.gold.withValues(alpha: 0.95)
              : (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: isDark ? 0.05 : 0.04),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: selected ? Colors.black : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sketchUploader() {
    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Sketch',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickSketch,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
              child: _sketchFile == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.draw_rounded, size: 34, color: AppColors.gold),
                        SizedBox(height: 10),
                        Text(
                          'Tap to upload sketch',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_sketchFile!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
          ),
          if (_sketchFile != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _sketchFile = null);
                },
                child: const Text('Remove sketch'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _promptSection() {
    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompt',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _promptController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'Describe the jewellery design you want...\nExample: elegant 22K rose gold engagement ring with floral diamond pattern',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdownCard(
                label: 'Category',
                value: _category,
                items: _categories,
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dropdownCard(
                label: 'Weight',
                value: _weight,
                items: _weights,
                onChanged: (v) => setState(() => _weight = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _dropdownCard(
                label: 'Material',
                value: _material,
                items: _materials,
                onChanged: (v) => setState(() => _material = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dropdownCard(
                label: 'Karat',
                value: _karat,
                items: _karats,
                onChanged: (v) => setState(() => _karat = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _dropdownCard(
                label: 'Style',
                value: _style,
                items: _styles,
                onChanged: (v) => setState(() => _style = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dropdownCard(
                label: 'Occasion',
                value: _occasion,
                items: _occasions,
                onChanged: (v) => setState(() => _occasion = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _dropdownCard(
          label: 'Budget Range',
          value: _budget,
          items: _budgets,
          onChanged: (v) => setState(() => _budget = v!),
        ),
      ],
    );
  }

  Widget _dropdownCard({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return AurixGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _generateButton() {
    return GestureDetector(
      onTap: _startGeneration,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.gold,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.black),
            SizedBox(width: 10),
            Text(
              'Generate Design',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}