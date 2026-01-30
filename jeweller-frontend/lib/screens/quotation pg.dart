import 'package:flutter/material.dart';

void main() {
  runApp(const AurixApp());
}

class AurixApp extends StatelessWidget {
  const AurixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurix',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFD4AF35),
        scaffoldBackgroundColor: const Color(0xFFF8F7F6),
        fontFamily: 'Manrope',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF35),
        scaffoldBackgroundColor: const Color(0xFF201D12),
        fontFamily: 'Manrope',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    QuotationScreen(),
    SearchScreen(),
    GoldRateScreen(),
    AIDesignScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF35),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Gold Rate'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Design'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

/// --------------------- QUOTATION SCREEN ---------------------
class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF201D12) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  const Spacer(),
                  Text(
                    'Quotation Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Quotation from Veni Jewellers',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Item Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAXCsUDUbSWW19GDg0hFd7JH2zQWbHEiNit7xIb_9j2yj67TfuUUKwP9dsKLSWfCYSfgOd7mi40lcq_qY8dZRBO9HIM_r7Kig2baO7PqJltnvM2bNMcIDCv9bE6ARthwMmJJkxEYs17v8zdp6NgF5sa2oxX4SWFXw2tu9oMyBKlKtStcgCwyzcy_n5WwiL9I-hPnLumk2FJqSPCF4qi9ZhK_TbtekMvCPAUgGtIIrcSu-yh5SbYYUB6bbUS5TXMPgmOxQJURfDflmF-'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Elegant Gold Bangle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Text('SKU: VJ-BG-0123', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Description List
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _priceRow('Gold Rate (per gram)', 'Rs5,500', isDark),
                          _priceRow('Weight', '10.2 gm', isDark),
                          _priceRow('Making Charges', 'Rs8,160', isDark),
                          _priceRow('Wastage', 'Rs2,750', isDark),
                          _priceRow('Stone Cost', 'Rs0', isDark),
                          _priceRow('Tax (GST)', 'Rs4,875', isDark),
                          const Divider(height: 20, color: Colors.grey),
                          _priceRow('Total Price', 'Rs71,885', isDark, isBold: true, fontSize: 18),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Validity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.schedule, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Valid Until: 28 Jul 2024, 11:59 PM',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80), // space for bottom buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF201D12) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: const Text('Accept Quote & Proceed to Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Ask for Revision', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  // Price Row helper
  Widget _priceRow(String title, String value, bool isDark, {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.grey[400] : Colors.grey)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}

/// --------------------- OTHER SCREENS ---------------------
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('🔍 Search Jewellery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }
}

class GoldRateScreen extends StatelessWidget {
  const GoldRateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gold Rate')),
      body: const Center(child: Text('📈 Today’s Gold Rate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }
}

class AIDesignScreen extends StatelessWidget {
  const AIDesignScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Design')),
      body: const Center(child: Text('✨ AI Jewellery Design', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: const Center(child: Text('👤 My Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }
}
