import 'package:flutter/material.dart';

enum VerificationState { pending, verified, rejected }

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  // For now: change this to test UI quickly
  final VerificationState status = VerificationState.pending;

  @override
  Widget build(BuildContext context) {
    final _StatusUI ui = _getStatusUI(status);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Verification Status',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gold.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(ui.icon, color: ui.color, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ui.title,
                          style: TextStyle(
                            color: ui.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _Badge(text: ui.badgeText, color: ui.color),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ui.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),

                  if (status == VerificationState.rejected) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Reason (example):',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uploaded licence document is unclear / expired. Please upload a valid copy.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What we verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _bullet('Jewellery licence / registration proof'),
                  _bullet('Shop details and contact info'),
                  _bullet('Identity verification (NIC/ID)'),
                  const SizedBox(height: 10),
                  Text(
                    'Verification builds trust and protects buyers from scams.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Action button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ui.buttonSnack)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  ui.buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFD4AF37))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  _StatusUI _getStatusUI(VerificationState s) {
    switch (s) {
      case VerificationState.pending:
        return _StatusUI(
          icon: Icons.hourglass_top,
          color: gold,
          title: 'Verification Pending',
          badgeText: 'PENDING',
          description:
              'Your documents were submitted successfully. Our admin team is reviewing them. '
              'This usually takes a short time.',
          buttonText: 'View Submitted Documents',
          buttonSnack: 'Submitted documents (UI later)',
        );
      case VerificationState.verified:
        return _StatusUI(
          icon: Icons.verified,
          color: Colors.greenAccent,
          title: 'You are Verified',
          badgeText: 'VERIFIED',
          description:
              'Your account is verified. Buyers will see your verified badge, increasing trust and conversions.',
          buttonText: 'Continue',
          buttonSnack: 'Continue (UI later)',
        );
      case VerificationState.rejected:
        return _StatusUI(
          icon: Icons.error_outline,
          color: Colors.redAccent,
          title: 'Verification Rejected',
          badgeText: 'REJECTED',
          description:
              'Your verification was rejected. Please review the reason and resubmit the required documents.',
          buttonText: 'Resubmit Documents',
          buttonSnack: 'Resubmit documents (UI later)',
        );
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusUI {
  final IconData icon;
  final Color color;
  final String title;
  final String badgeText;
  final String description;
  final String buttonText;
  final String buttonSnack;

  _StatusUI({
    required this.icon,
    required this.color,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.buttonText,
    required this.buttonSnack,
  });
}