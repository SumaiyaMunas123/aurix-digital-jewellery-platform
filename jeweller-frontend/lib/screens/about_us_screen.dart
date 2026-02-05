import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFD4AF35);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isDark),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(isDark),
                  _buildFAQTab(isDark),
                  _buildContactTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? const Color(0xFF2A271A) : Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'About & Help',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A271A) : Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: primaryColor,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'About Us'),
          Tab(text: 'FAQ'),
          Tab(text: 'Contact'),
        ],
      ),
    );
  }

  // ABOUT US TAB
  Widget _buildAboutTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.diamond,
                size: 60,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // App Name
          Center(
            child: Text(
              'AURIX',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? primaryColor : const Color(0xFF303030),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Premium Jewellery Marketplace',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // About Description
          _buildSectionTitle('Our Story', isDark),
          _buildDescriptionCard(
            isDark,
            'AURIX is Sri Lanka\'s premier online jewellery marketplace, connecting customers with verified jewellers and craftsmen. We bring together centuries of traditional craftsmanship with modern technology to create a seamless shopping experience.',
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Our Mission', isDark),
          _buildDescriptionCard(
            isDark,
            'To revolutionize the jewellery shopping experience by providing a trusted platform where customers can discover, compare, and purchase authentic jewellery from verified sellers with complete confidence.',
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Why Choose AURIX?', isDark),
          _buildFeatureItem(isDark, Icons.verified_user, 'Verified Sellers', 'All jewellers are thoroughly verified and certified'),
          const SizedBox(height: 12),
          _buildFeatureItem(isDark, Icons.security, 'Secure Transactions', 'Your payments and data are completely secure'),
          const SizedBox(height: 12),
          _buildFeatureItem(isDark, Icons.diamond, 'Quality Assured', 'Every piece meets our strict quality standards'),
          const SizedBox(height: 12),
          _buildFeatureItem(isDark, Icons.local_shipping, 'Insured Delivery', 'Free insured shipping on all orders'),
          const SizedBox(height: 32),
          
          // Version Info
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2024 AURIX. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FAQ TAB
  Widget _buildFAQTab(bool isDark) {
    final faqs = [
      {
        'question': 'How do I place an order?',
        'answer': 'Browse products, add items to cart, and proceed to checkout. You can pay securely using our integrated payment system.'
      },
      {
        'question': 'Are all sellers verified?',
        'answer': 'Yes, all jewellers on AURIX undergo strict verification including business registration, certification checks, and quality audits.'
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': 'We accept credit/debit cards, bank transfers, and digital wallets. All payments are processed securely.'
      },
      {
        'question': 'How long does delivery take?',
        'answer': 'Standard delivery takes 3-5 business days within Colombo and 5-7 days to other areas. Express delivery is available.'
      },
      {
        'question': 'What is your return policy?',
        'answer': 'We offer a 7-day return policy for unused items in original condition. Custom-made items may have different terms.'
      },
      {
        'question': 'Is the jewellery authentic?',
        'answer': 'Absolutely. All gold items come with purity certificates, and gemstones are certified by recognized laboratories.'
      },
      {
        'question': 'Can I get custom designs made?',
        'answer': 'Yes! Many of our jewellers offer custom design services. Contact them directly through the chat feature.'
      },
      {
        'question': 'How do I track my order?',
        'answer': 'Once shipped, you\'ll receive a tracking number via SMS and email. You can also track in the app under "My Orders".'
      },
      {
        'question': 'What if I receive a damaged item?',
        'answer': 'Contact us immediately with photos. We\'ll arrange a replacement or full refund including return shipping.'
      },
      {
        'question': 'How can I contact a seller?',
        'answer': 'Use the in-app chat feature on any product or shop page to communicate directly with sellers.'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(
          isDark,
          faqs[index]['question']!,
          faqs[index]['answer']!,
        );
      },
    );
  }

  // CONTACT TAB
  Widget _buildContactTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Get In Touch', isDark),
          const SizedBox(height: 16),
          
          // Contact Methods
          _buildContactCard(
            isDark,
            Icons.phone,
            'Phone',
            '+94 11 234 5678',
            'Call us Mon-Sat, 9AM-6PM',
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            isDark,
            Icons.email,
            'Email',
            'support@aurix.lk',
            'We\'ll respond within 24 hours',
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            isDark,
            Icons.chat,
            'Live Chat',
            'Available 24/7',
            'Get instant support',
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            isDark,
            Icons.location_on,
            'Address',
            '123 Galle Road, Colombo 03',
            'Sri Lanka',
          ),
          
          const SizedBox(height: 32),
          
          // Social Media
          _buildSectionTitle('Follow Us', isDark),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(isDark, Icons.facebook, 'Facebook'),
              _buildSocialButton(isDark, Icons.camera_alt, 'Instagram'),
              _buildSocialButton(isDark, Icons.play_arrow, 'YouTube'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Contact Form
          _buildSectionTitle('Send us a Message', isDark),
          const SizedBox(height: 16),
          _buildContactForm(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? primaryColor : const Color(0xFF303030),
      ),
    );
  }

  Widget _buildDescriptionCard(bool isDark, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeatureItem(bool isDark, IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(bool isDark, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          iconColor: primaryColor,
          collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(bool isDark, IconData icon, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(bool isDark, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $label...')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A271A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Your Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
