import 'package:aurix/core/network/api_client.dart';

import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoApi implements ProductRepository {
  @override
  Future<List<Product>> getAll() async {
    try {
      final response = await ApiClient.instance.dio.get('/products');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => Product(
                    id: item['id'] ?? '',
                    name: item['name'] ?? 'Unknown',
                    jeweller: item['jeweller'] ?? '',
                    karat: item['karat'] ?? '18K',
                    weight: item['weight'] ?? '0',
                    priceLkr: item['priceLkr'] as int?,
                    category: item['category'] ?? '',
                    isDeal: item['isDeal'] == true,
                    isNew: item['isNew'] == true,
                    isFeatured: item['isFeatured'] == true,
                    isTrending: item['isTrending'] == true,
                  ))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }
}