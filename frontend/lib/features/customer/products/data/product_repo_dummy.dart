import 'package:aurix/dev/dummy_data/dummy_products.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoDummy implements ProductRepository {
  @override
  Future<List<Product>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return DummyProducts.items.map((e) => Product.fromMap(e)).toList();
  }
}