import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import 'data/cart_store.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartStore>();

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
                      'Cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${cart.itemCount}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 12),
              if (cart.items.isEmpty)
                const AurixGlassCard(
                  child: Text(
                    'No items in cart yet.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                )
              else ...[
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AurixGlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.jeweller,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.priceLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: () => cart.decreaseQuantity(item.id),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: () => cart.increaseQuantity(item.id),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => cart.removeItem(item.id),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AurixGlassCard(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Subtotal',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      Text(
                        cart.subtotalLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: cart.clear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Clear Cart',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
