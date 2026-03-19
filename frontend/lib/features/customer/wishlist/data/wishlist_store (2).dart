import 'package:flutter/foundation.dart';

class WishlistStore extends ChangeNotifier {
  final Set<String> _ids = {};

  bool contains(String productId) => _ids.contains(productId);

  void toggle(String productId) {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();
  }

  List<String> get ids => _ids.toList(growable: false);
}