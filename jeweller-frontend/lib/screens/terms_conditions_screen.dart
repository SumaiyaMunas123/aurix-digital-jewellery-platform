import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Aurix',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'These terms and conditions outline the rules and regulations for the use of Aurix\'s Website and mobile application. By accessing this application, we assume you accept these terms and conditions.',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. User Accounts',
              'When you create an account with us, you must provide us with information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service. You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password.',
              isDark,
            ),
            
            _buildSection(
              '2. Purchases and Payments',
              'If you wish to purchase any product or service made available through the Service ("Purchase"), you may be asked to supply certain information relevant to your Purchase including, without limitation, your credit card number, the expiration date of your credit card, your billing address, and your shipping information. You represent and warrant that you have the legal right to use any credit card(s) or other payment method(s) in connection with any Purchase.',
              isDark,
            ),
            
            _buildSection(
              '3. Product Information',
              'We strive to provide accurate product descriptions and pricing. However, we do not warrant that product descriptions, pricing, or other content on our Service is accurate, complete, reliable, current, or error-free. All jewellery items are subject to availability.',
              isDark,
            ),
            
            _buildSection(
              '4. Returns and Refunds',
              'Our return policy allows you to return products within 14 days of purchase. Items must be in original condition with all tags attached. Custom-made or personalized items cannot be returned unless defective.',
              isDark,
            ),
            
            _buildSection(
              '5. Privacy Policy',
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using our Service, you agree to the collection and use of information in accordance with our Privacy Policy.',
              isDark,
            ),
            
            _buildSection(
              '6. Intellectual Property',
              'The Service and its original content, features, and functionality are and will remain the exclusive property of Aurix and its licensors. Our trademarks and trade dress may not be used in connection with any product or service without prior written consent.',
              isDark,
            ),
            
            _buildSection(
              '7. Limitation of Liability',
              'In no event shall Aurix, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages arising out of your use of the Service.',
              isDark,
            ),
            
            _buildSection(
              '8. Changes to Terms',
              'We reserve the right to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
              isDark,
            ),
            
            _buildSection(
              '9. Contact Us',
              'If you have any questions about these Terms, please contact us through our customer support available in the app.',
              isDark,
            ),
            
            const SizedBox(height: 20),
            
            Center(
              child: Text(
                'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[800],
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
