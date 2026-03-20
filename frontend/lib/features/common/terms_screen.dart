import 'package:flutter/material.dart';

import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Terms & Conditions',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              _section(
                title: '1. Account Use',
                text:
                    'Users must provide accurate account information. Account access is personal and should not be shared with others.',
              ),
              _section(
                title: '2. Product Information',
                text:
                    'Prices, karat values, and product details are displayed as provided by jewellers. Final purchase terms are confirmed during checkout or quotation approval.',
              ),
              _section(
                title: '3. Quotations',
                text:
                    'Quotation responses may vary by jeweller and product customization. Quotations do not guarantee stock availability until confirmed.',
              ),
              _section(
                title: '4. Privacy & Security',
                text:
                    'Aurix stores profile and interaction data to improve service quality. Sensitive data is handled using secure application practices.',
              ),
              _section(
                title: '5. Platform Conduct',
                text:
                    'Users and jewellers are expected to maintain respectful communication and lawful use of the platform.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AurixGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
