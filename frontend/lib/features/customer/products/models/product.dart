class Product {
  final String id;
  final String name;
  final String? description;
  final String jeweller;
  final String karat;
  final String weight;
  final int? priceLkr;
  final String category;
  final String? imageUrl;

  final bool isDeal;
  final bool isNew;
  final bool isFeatured;
  final bool isTrending;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.jeweller,
    required this.karat,
    required this.weight,
    this.priceLkr,
    required this.category,
    this.imageUrl,
    required this.isDeal,
    required this.isNew,
    required this.isFeatured,
    required this.isTrending,
  });

  String get priceLabel => priceLkr == null ? "Ask Price" : "LKR $priceLkr";

  factory Product.fromMap(Map<String, dynamic> m) {
    return Product(
      id: (m["id"] ?? "").toString(),
      name: (m["name"] ?? "").toString(),
      description: (m["description"] ?? "").toString(),
      jeweller: (m["jeweller_name"] ?? m["jeweller"] ?? "").toString(),
      karat: (m["karat"] ?? "").toString(),
      weight: (m["weight"] ?? "").toString(),
      priceLkr: (m["price_lkr"] is int) ? m["price_lkr"] as int : null,
      category: (m["category"] ?? "").toString(),
      imageUrl: (m["image_url"] ?? "").toString(),
      isDeal: m["is_deal"] == true || m["isDeal"] == true,
      isNew: m["is_new"] == true || m["isNew"] == true,
      isFeatured: m["is_featured"] == true || m["isFeatured"] == true,
      isTrending: m["is_trending"] == true || m["isTrending"] == true,
    );
  }
}