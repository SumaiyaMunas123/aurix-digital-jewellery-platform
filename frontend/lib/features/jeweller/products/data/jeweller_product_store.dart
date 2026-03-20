import 'package:flutter/foundation.dart';

class JewellerProduct {
  final String id;
  final String name;
  final String price;
  final String description;
  final String category;
  final String material;
  final String karat;
  final String weight;
  final String status;
  final String imagePath;

  const JewellerProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.material,
    required this.karat,
    required this.weight,
    required this.status,
    required this.imagePath,
  });

  JewellerProduct copyWith({
    String? id,
    String? name,
    String? price,
    String? description,
    String? category,
    String? material,
    String? karat,
    String? weight,
    String? status,
    String? imagePath,
  }) {
    return JewellerProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      material: material ?? this.material,
      karat: karat ?? this.karat,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class JewellerProductStore extends ChangeNotifier {
  final List<JewellerProduct> _products = [
    const JewellerProduct(
      id: 'jp1',
      name: '22K Gold Ring',
      price: '85000',
      description: 'Elegant classic ring design.',
      category: 'Ring',
      material: 'Gold',
      karat: '22K',
      weight: '2g - 5g',
      status: 'Active',
      imagePath: '',
    ),
    const JewellerProduct(
      id: 'jp2',
      name: 'Bridal Necklace Set',
      price: '240000',
      description: 'Bridal set with premium finish.',
      category: 'Necklace',
      material: 'Gold',
      karat: '22K',
      weight: '10g - 20g',
      status: 'Active',
      imagePath: '',
    ),
    const JewellerProduct(
      id: 'jp3',
      name: 'Rose Gold Pendant',
      price: '62000',
      description: 'Minimal pendant for daily wear.',
      category: 'Pendant',
      material: 'Rose Gold',
      karat: '18K',
      weight: '2g - 5g',
      status: 'Draft',
      imagePath: '',
    ),
  ];

  List<JewellerProduct> get products => List.unmodifiable(_products);

  void addProduct(JewellerProduct product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(JewellerProduct product) {
    final index = _products.indexWhere((e) => e.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    notifyListeners();
  }

  void updateStatus(String id, String status) {
    final index = _products.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _products[index] = _products[index].copyWith(status: status);
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
