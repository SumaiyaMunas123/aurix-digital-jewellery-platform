import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import '../../customer/quotations/data/quotation_store.dart';

class QuotationReplyScreen extends StatefulWidget {
  final QuotationRequest request;

  const QuotationReplyScreen({
    super.key,
    required this.request,
  });

  @override
  State<QuotationReplyScreen> createState() => _QuotationReplyScreenState();
}

class _QuotationReplyScreenState extends State<QuotationReplyScreen> {
  final _priceController = TextEditingController();
  final _replyController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _priceController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a quotation price.')),
      );
      return;
    }

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    context.read<QuotationStore>().updateStatus(widget.request.id, 'Replied');

    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quotation reply sent.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

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
                      'Reply Quotation',
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
                      request.productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer: ${request.customerName}',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Size: ${request.size}'),
                    Text('Quantity: ${request.quantity}'),
                    const SizedBox(height: 8),
                    Text(
                      'Notes: ${request.notes.isEmpty ? 'No notes' : request.notes}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Quotation Price (LKR)',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _replyController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Reply message to customer',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _sending ? null : _sendReply,
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
                            'Send Reply',
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