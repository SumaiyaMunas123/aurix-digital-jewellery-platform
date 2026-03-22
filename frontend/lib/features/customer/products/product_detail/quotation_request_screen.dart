import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_background.dart';
import '../../../../core/widgets/aurix_glass_card.dart';
import '../../../customer/quotations/data/quotation_store.dart';

class QuotationRequestScreen extends StatefulWidget {
  final String productName;
  final String jewellerName;

  const QuotationRequestScreen({
    super.key,
    required this.productName,
    required this.jewellerName,
  });

  @override
  State<QuotationRequestScreen> createState() => _QuotationRequestScreenState();
}

class _QuotationRequestScreenState extends State<QuotationRequestScreen> {
  final _notesController = TextEditingController();
  String _selectedSize = 'Standard';
  String _selectedQuantity = '1';

  final sizes = const ['Standard', 'Small', 'Medium', 'Large', 'Custom'];
  final quantities = const ['1', '2', '3', '4', '5+'];

  bool _sending = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    setState(() => _sending = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    context.read<QuotationStore>().addRequest(
          QuotationRequest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            productName: widget.productName,
            jewellerName: widget.jewellerName,
            customerName: 'Achchu',
            size: _selectedSize,
            quantity: _selectedQuantity,
            notes: _notesController.text.trim(),
            createdAt: DateTime.now(),
          ),
        );

    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quotation request sent successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Get Quotation',
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
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.jewellerName,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred Size',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSize,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: sizes
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSize = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Quantity',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedQuantity,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: quantities
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedQuantity = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Extra notes (design changes, stone type, deadline...)',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _sending ? null : _sendRequest,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.gold,
                  ),
                  child: Center(
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Send Request',
                            style: TextStyle(
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