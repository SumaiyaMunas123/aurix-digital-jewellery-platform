import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_jewellers.dart';

import '../models/ai_generation_request.dart';

class QuotationJewellerSelectScreen extends StatefulWidget {
  final AiGenerationRequest request;

  const QuotationJewellerSelectScreen({
    super.key,
    required this.request,
  });

  @override
  State<QuotationJewellerSelectScreen> createState() =>
      _QuotationJewellerSelectScreenState();
}

class _QuotationJewellerSelectScreenState
    extends State<QuotationJewellerSelectScreen> {
  final Set<int> _selectedIndexes = {};

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _toggleSelection(int index) {
    HapticFeedback.selectionClick();

    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        return;
      }

      if (_selectedIndexes.length >= 3) {
        _showSnack('You can send to up to 3 jewellers at a time.');
        return;
      }

      _selectedIndexes.add(index);
    });
  }

  void _sendQuotationRequest() {
    if (_selectedIndexes.isEmpty) {
      _showSnack('Select at least 1 jeweller.');
      return;
    }

    final names = _selectedIndexes
        .map((i) => DummyJewellers.items[i]["name"]!)
        .join(', ');

    _showSnack('Quotation request sent to: $names');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final jewellers = DummyJewellers.items;

    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Select Jewellers',
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  'Select up to 3 jewellers to request quotations.',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: jewellers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final jeweller = jewellers[index];
                    final selected = _selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () => _toggleSelection(index),
                      child: AurixGlassCard(
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jeweller["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    jeweller["city"]!,
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? AppColors.gold
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.gold
                                      : AppColors.gold.withValues(alpha: 0.25),
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: GestureDetector(
                  onTap: _sendQuotationRequest,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.gold,
                    ),
                    child: Text(
                      'Send to Selected (${_selectedIndexes.length}/3)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}