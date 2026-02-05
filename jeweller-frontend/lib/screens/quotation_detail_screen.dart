import 'package:flutter/material.dart';

class QuotationDetailScreen extends StatelessWidget {
  const QuotationDetailScreen({super.key});

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quotation Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF201D12) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
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
                            Text('Elegant Gold Bangle',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('SKU: VJ-BG-0123',
                                style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                        _priceRow('Gold Rate (per gram)', 'Rs 5,500', isDark),
                        _priceRow('Weight', '10.2 gm', isDark),
                        _priceRow('Making Charges', 'Rs 8,160', isDark),
                        _priceRow('Wastage', 'Rs 2,750', isDark),
                        _priceRow('Stone Cost', 'Rs 0', isDark),
                        _priceRow('Tax (GST)', 'Rs 4,875', isDark),
                        const Divider(height: 20, color: Colors.grey),
                        _priceRow('Total Price', 'Rs 71,885', isDark,
                            isBold: true, fontSize: 18),
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF201D12) : Colors.white,
          border: Border(
            top: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proceeding to Payment')),
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text('Accept Quote & Proceed to Payment',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request for Revision sent')),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Ask for Revision',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  // Price Row helper
  Widget _priceRow(String title, String value, bool isDark,
      {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.grey[400] : Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}
