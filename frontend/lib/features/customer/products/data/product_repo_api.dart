import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoApi implements ProductRepository {
  @override
  Future<List<Product>> getAll() async {
    // TODO: integrate backend
    return [];
  }
}