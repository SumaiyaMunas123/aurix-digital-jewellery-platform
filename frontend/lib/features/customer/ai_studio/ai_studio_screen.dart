import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/features/customer/ai_studio/data/ai_studio_api.dart';

class AiStudioScreen extends StatefulWidget {
  const AiStudioScreen({super.key});

  @override
  State<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends State<AiStudioScreen> {
  final _promptCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  Uint8List? _imageBytes;
  String? _imageUrl;

  String _userType = 'customer';
  String _jewelryType = 'ring';
  String _material = 'gold';
  String _gemstone = 'diamond';
  String _style = 'modern';
  String _finish = 'polished';

  @override
  void dispose() {
    _promptCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) {
      setState(() => _error = 'Prompt is required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await AiStudioApi.instance.generateStyled(
        prompt: prompt,
        userType: _userType,
        userId: _userIdCtrl.text.trim().isEmpty ? null : _userIdCtrl.text.trim(),
        style: {
          'jewelry_type': _jewelryType,
          'material': _material,
          'gemstone': _gemstone,
          'style': _style,
          'finish': _finish,
        },
      );

      final base64 = data['image_base64']?.toString();
      setState(() {
        _imageBytes = (base64 != null && base64.isNotEmpty)
            ? base64Decode(base64)
            : null;
        _imageUrl = data['image_url']?.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Studio', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              const Text(
                'Generate jewellery designs from prompts with style controls.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Prompt',
                  hintText: 'Elegant engagement ring with floral details',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _userIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'User ID (optional UUID)',
                ),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'User Type',
                value: _userType,
                items: const ['customer', 'jeweller'],
                onChanged: (v) => setState(() => _userType = v ?? 'customer'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Jewelry Type',
                value: _jewelryType,
                items: const ['ring', 'necklace', 'bracelet', 'earring', 'pendant'],
                onChanged: (v) => setState(() => _jewelryType = v ?? 'ring'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Material',
                value: _material,
                items: const ['gold', 'silver', 'platinum', 'rose gold'],
                onChanged: (v) => setState(() => _material = v ?? 'gold'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Gemstone',
                value: _gemstone,
                items: const ['diamond', 'ruby', 'sapphire', 'emerald', 'none'],
                onChanged: (v) => setState(() => _gemstone = v ?? 'diamond'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Style',
                value: _style,
                items: const ['modern', 'classic', 'minimal', 'traditional', 'luxury'],
                onChanged: (v) => setState(() => _style = v ?? 'modern'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Finish',
                value: _finish,
                items: const ['polished', 'matte', 'brushed'],
                onChanged: (v) => setState(() => _finish = v ?? 'polished'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _generate,
                  child: Text(_loading ? 'Generating...' : 'Generate Design'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        if (_imageBytes != null) ...[
          const SizedBox(height: 12),
          AurixGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Generated Preview', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_imageBytes!, width: double.infinity, fit: BoxFit.cover),
                ),
                if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    _imageUrl!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}