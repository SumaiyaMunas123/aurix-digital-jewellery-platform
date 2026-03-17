class Product {
  final String id;
  final String name;
  final String jeweller;
  final String karat;
  final String weight;
  final int? priceLkr;
  final String category;

  final bool isDeal;
  final bool isNew;
  final bool isFeatured;
  final bool isTrending;

  const Product({
    required this.id,
    required this.name,
    required this.jeweller,
    required this.karat,
    required this.weight,
    required this.priceLkr,
    required this.category,
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
      jeweller: (m["jeweller"] ?? "").toString(),
      karat: (m["karat"] ?? "").toString(),
      weight: (m["weight"] ?? "").toString(),
      priceLkr: (m["priceLkr"] is int) ? m["priceLkr"] as int : null,
      category: (m["category"] ?? "").toString(),
      isDeal: m["isDeal"] == true,
      isNew: m["isNew"] == true,
      isFeatured: m["isFeatured"] == true,
      isTrending: m["isTrending"] == true,
    );
  }
}