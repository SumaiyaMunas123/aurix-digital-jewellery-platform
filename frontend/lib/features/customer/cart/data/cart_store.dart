import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String jeweller;
  final String priceLabel;
  final int? unitPriceLkr;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.jeweller,
    required this.priceLabel,
    this.unitPriceLkr,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? jeweller,
    String? priceLabel,
    int? unitPriceLkr,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      jeweller: jeweller ?? this.jeweller,
      priceLabel: priceLabel ?? this.priceLabel,
      unitPriceLkr: unitPriceLkr ?? this.unitPriceLkr,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartStore extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get subtotalLkr => _items.fold<int>(
        0,
        (sum, item) => sum + ((item.unitPriceLkr ?? 0) * item.quantity),
      );

  String get subtotalLabel =>
      subtotalLkr <= 0 ? 'Ask Price' : 'LKR $subtotalLkr';

  bool contains(String id) {
    return _items.any((e) => e.id == id);
  }

  void addItem({
    required String id,
    required String name,
    required String jeweller,
    required String priceLabel,
    int? unitPriceLkr,
  }) {
    final index = _items.indexWhere((e) => e.id == id);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          jeweller: jeweller,
          priceLabel: priceLabel,
          unitPriceLkr: unitPriceLkr,
        ),
      );
    }

    notifyListeners();
  }

  void increaseQuantity(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;

    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return;

    final item = _items[index];
    if (item.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    }

    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
