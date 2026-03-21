import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_background.dart';
import '../../../../core/widgets/aurix_glass_card.dart';
import '../../cart/cart_screen.dart';
import '../../cart/data/cart_store.dart';
import '../../wishlist/data/wishlist_store.dart';
import '../models/product.dart';
import 'quotation_request_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isInWishlist = false;
  bool _wishlistSynced = false;

  Map<String, dynamic> _asMap(dynamic source) {
    if (source is Product) {
      return {
        'id': source.id,
        'name': source.name,
        'jeweller': source.jeweller,
        'karat': source.karat,
        'weight': source.weight,
        'category': source.category,
        'priceLkr': source.priceLkr,
      };
    }

    if (source is Map<String, dynamic>) return source;

    if (source is Map) {
      return source.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return {};
  }

  String _readString(
      Map<String, dynamic> source, String field, String fallback) {
    final value = source[field];
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  int? _readInt(Map<String, dynamic> source, String field) {
    final value = source[field];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _productId(Map<String, dynamic> p) =>
      _readString(p, 'id', DateTime.now().millisecondsSinceEpoch.toString());

  bool _isAskPrice(Map<String, dynamic> p) {
    final priceLkr = _readInt(p, 'priceLkr');
    return priceLkr == null || priceLkr <= 0;
  }

  String _priceLabel(Map<String, dynamic> p) {
    final priceLkr = _readInt(p, 'priceLkr');
    return priceLkr == null || priceLkr <= 0 ? 'Ask Price' : 'LKR $priceLkr';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wishlistSynced) return;

    final productMap = _asMap(widget.product);
    final productId = _productId(productMap);
    isInWishlist = context.read<WishlistStore>().contains(productId);
    _wishlistSynced = true;
  }

  @override
  Widget build(BuildContext context) {
    final productMap = _asMap(widget.product);
    final title = _readString(productMap, 'name', 'Jewellery Product');
    final jeweller = _readString(productMap, 'jeweller', 'Aurix Jeweller');
    final description = _readString(
      productMap,
      'description',
      'Beautiful jewellery piece',
    );
    final priceText = _priceLabel(productMap);
    final askPrice = _isAskPrice(productMap);
    final productId = _productId(productMap);

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
                      'Product Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Container(
                  height: 240,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.20),
                    ),
                  ),
                  child: _readString(productMap, 'image_url', '').isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _readString(productMap, 'image_url', ''),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: AppColors.gold,
                            ),
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.gold,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: AppColors.gold,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jeweller,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: askPrice
                            ? AppColors.gold.withValues(alpha: 0.16)
                            : AppColors.gold.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        priceText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecRow('Metal Type',
                        _readString(productMap, 'metal_type', 'Gold')),
                    _buildSpecRow(
                        'Karat', _readString(productMap, 'karat', '-')),
                    _buildSpecRow(
                        'Weight', _readString(productMap, 'weight', '-')),
                    _buildSpecRow('Category',
                        _readString(productMap, 'category', 'Jewellery')),
                    _buildSpecRow('Making Charge',
                        'LKR ${_readString(productMap, 'making_charge', '0')}'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AurixGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: quantity > 1
                              ? () {
                                  setState(() => quantity--);
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(Icons.remove, size: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => quantity++);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<WishlistStore>().toggle(productId);
                      final current =
                          context.read<WishlistStore>().contains(productId);
                      setState(() => isInWishlist = current);
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            current
                                ? 'Added to wishlist'
                                : 'Removed from wishlist',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isInWishlist
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.28),
                        ),
                        color: isInWishlist
                            ? AppColors.gold.withValues(alpha: 0.12)
                            : null,
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? AppColors.gold : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!askPrice)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final price = _readInt(productMap, 'priceLkr');
                          for (var i = 0; i < quantity; i++) {
                            context.read<CartStore>().addItem(
                                  id: productId,
                                  name: title,
                                  jeweller: jeweller,
                                  priceLabel: priceText,
                                  unitPriceLkr: price,
                                );
                          }
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $quantity item(s) to cart'),
                            ),
                          );
                          
                          // Navigate to cart screen
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Add to Cart',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!askPrice) const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuotationRequestScreen(
                              productName: title,
                              jewellerName: jeweller,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.gold,
                        ),
                        child: const Center(
                          child: Text(
                            'Quotation',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
