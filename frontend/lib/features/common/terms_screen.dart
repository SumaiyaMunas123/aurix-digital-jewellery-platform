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
                      "Terms & Conditions",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              const AurixGlassCard(
                child: Text(
                  "Terms and conditions content will be added here later. This page is ready for backend/content integration.",
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}