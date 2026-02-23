import 'package:flutter/material.dart';
import 'verification_status_screen.dart';
import 'manage_listings_screen.dart';
import 'add_jewellery_screen.dart';
import 'enquiries_screen.dart';
import 'chat_list_screen.dart';

class JewellerDashboard extends StatelessWidget {
  const JewellerDashboard({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Jeweller Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            _tile(context, Icons.inventory_2, 'Manage Listings',
                ManageListingsScreen()),
            _tile(context, Icons.add_box, 'Add Jewellery',
                AddJewelleryScreen()),
            _tile(context, Icons.mail_outline, 'Enquiries',
                EnquiriesScreen()),
            _tile(context, Icons.chat_bubble_outline, 'Messages',
                ChatListScreen()),
            _tile(context, Icons.verified, 'Verification',
                VerificationStatusScreen()),
          ],
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, IconData icon, String title, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: gold),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}