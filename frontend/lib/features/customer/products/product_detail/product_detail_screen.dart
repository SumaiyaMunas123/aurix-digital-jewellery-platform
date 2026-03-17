import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/core/theme/app_colors.dart';

import 'package:aurix/features/customer/chat/chat_room/chat_room_screen.dart';
import 'package:aurix/core/navigation/nav.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          AurixGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Product Details", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                _row("Jeweller", product.jeweller),
                _row("Karat", product.karat),
                _row("Weight", product.weight),
                _row("Category", product.category),
                _row("Price", product.priceLabel),
              ],
            ),
          ),
          const SizedBox(height: 14),

          AurixGlassCard(
            child: Row(
              children: [
                Expanded(
                  child: _button(
                    label: "Chat",
                    icon: Icons.chat_bubble_rounded,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Nav.push(context, ChatRoomScreen(title: product.jeweller));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    label: "Add to Wishlist",
                    icon: Icons.favorite_rounded,
                    onTap: () => HapticFeedback.selectionClick(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _button({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}