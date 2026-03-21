import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoApi implements ProductRepository {
  final _apiClient = ApiClient.instance;

  @override
  Future<List<Product>> getAll() async {
    try {
      print('🛍️ Fetching all products...');
      final response = await _apiClient.dio.get('/products');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch products');
      }

      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      final productsList = data['data'] as List? ?? [];
      final products = productsList
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList();

      print('✅ Fetched ${products.length} products');
      return products;
    } on DioException catch (e) {
      print('❌ Error fetching products: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}