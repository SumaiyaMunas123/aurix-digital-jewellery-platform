import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<int> _wishlist = {};
  final TextEditingController _searchController = TextEditingController();

  final categories = ['All', 'Rings', 'Necklaces', 'Earrings', 'Bracelets', 'Bangles'];

  void _toggleWishlist(int productId) {
    setState(() {
      if (_wishlist.contains(productId)) {
        _wishlist.remove(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist')),
        );
      } else {
        _wishlist.add(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              color: isDark ? const Color(0xFF2A271A) : Colors.white,
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF171612),
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for jewellery...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF201D12)
                      : const Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Category Tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedCategory == categories[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = categories[i];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                ? const Color(0xFF2A271A)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        categories[i],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Products Grid
            Expanded(
              child: _buildProductsGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(bool isDark) {
    // All products database
    final allProducts = [
      {'id': 1, 'name': 'Gold Ring', 'price': 'Rs 45,000', 'category': 'Rings'},
      {'id': 7, 'name': 'Diamond Ring', 'price': 'Rs 150,000', 'category': 'Rings'},
      {'id': 6, 'name': 'Ruby Ring', 'price': 'Rs 85,000', 'category': 'Rings'},
      {'id': 8, 'name': 'Emerald Ring', 'price': 'Rs 95,000', 'category': 'Rings'},
      {'id': 9, 'name': 'Gold Necklace', 'price': 'Rs 125,000', 'category': 'Necklaces'},
      {'id': 2, 'name': 'Diamond Necklace', 'price': 'Rs 250,000', 'category': 'Necklaces'},
      {'id': 10, 'name': 'Pearl Necklace', 'price': 'Rs 75,000', 'category': 'Necklaces'},
      {'id': 3, 'name': 'Pearl Earrings', 'price': 'Rs 35,000', 'category': 'Earrings'},
      {'id': 11, 'name': 'Diamond Earrings', 'price': 'Rs 120,000', 'category': 'Earrings'},
      {'id': 12, 'name': 'Gold Earrings', 'price': 'Rs 45,000', 'category': 'Earrings'},
      {'id': 4, 'name': 'Gold Bracelet', 'price': 'Rs 65,000', 'category': 'Bracelets'},
      {'id': 13, 'name': 'Silver Bracelet', 'price': 'Rs 35,000', 'category': 'Bracelets'},
      {'id': 14, 'name': 'Diamond Bracelet', 'price': 'Rs 180,000', 'category': 'Bracelets'},
      {'id': 15, 'name': 'Gold Bangle', 'price': 'Rs 55,000', 'category': 'Bangles'},
      {'id': 5, 'name': 'Silver Bangle', 'price': 'Rs 25,000', 'category': 'Bangles'},
      {'id': 16, 'name': 'Designer Bangle', 'price': 'Rs 95,000', 'category': 'Bangles'},
    ];

    // Filter by category
    var filteredProducts = _selectedCategory == 'All'
        ? allProducts
        : allProducts.where((p) => p['category'] == _selectedCategory).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) {
        final name = (p['name'] as String).toLowerCase();
        final category = (p['category'] as String).toLowerCase();
        return name.contains(_searchQuery) || category.contains(_searchQuery);
      }).toList();
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results found for "$_searchQuery"'
                  : 'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text(
                  'Clear search',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, i) {
        final product = filteredProducts[i];
        final productId = product['id'] as int;
        final isInWishlist = _wishlist.contains(productId);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductDetailScreen(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A271A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.diamond,
                          size: 50,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleWishlist(productId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isInWishlist ? Colors.red : primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']! as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['price']! as String,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['category']! as String,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
