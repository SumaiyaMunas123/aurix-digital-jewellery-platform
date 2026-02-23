import 'package:flutter/material.dart';
import 'add_jewellery_screen.dart';

class ManageListingsScreen extends StatelessWidget {
  const ManageListingsScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  final List<_Listing> listings = const [
    _Listing(
      title: '22K Gold Ring',
      category: 'Rings',
      priceText: 'LKR 185,000',
      status: _ListingStatus.active,
    ),
    _Listing(
      title: 'Custom Necklace',
      category: 'Necklaces',
      priceText: 'Ask Price',
      status: _ListingStatus.active,
    ),
    _Listing(
      title: '18K Bracelet',
      category: 'Bracelets',
      priceText: 'LKR 92,500',
      status: _ListingStatus.hidden,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Listings',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddJewelleryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = listings[index];
          return _ListingCard(listing: item);
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final _Listing listing;

  const _ListingCard({required this.listing});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  @override
  Widget build(BuildContext context) {
    final statusUI = _statusUI(listing.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Top Row
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(Icons.image_outlined, color: Colors.white54),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.category,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          listing.priceText,
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _Badge(text: statusUI.text, color: statusUI.color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit listing (later)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          listing.status == _ListingStatus.active
                              ? 'Listing hidden (UI only)'
                              : 'Listing unhidden (UI only)',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    listing.status == _ListingStatus.active
                        ? 'Hide'
                        : 'Unhide',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete listing (later)')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusUI _statusUI(_ListingStatus s) {
    switch (s) {
      case _ListingStatus.active:
        return const _StatusUI(text: 'ACTIVE', color: Colors.greenAccent);
      case _ListingStatus.hidden:
        return const _StatusUI(text: 'HIDDEN', color: Colors.orangeAccent);
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
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

enum _ListingStatus { active, hidden }

class _Listing {
  final String title;
  final String category;
  final String priceText;
  final _ListingStatus status;

  const _Listing({
    required this.title,
    required this.category,
    required this.priceText,
    required this.status,
  });
}

class _StatusUI {
  final String text;
  final Color color;

  const _StatusUI({required this.text, required this.color});
}