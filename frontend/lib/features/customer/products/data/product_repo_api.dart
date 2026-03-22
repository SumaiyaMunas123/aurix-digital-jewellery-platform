import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoApi implements ProductRepository {
  final _apiClient = ApiClient.instance;

  @override
  Future<List<Product>> getAll() async {
    try {
      final response = await _apiClient.dio.get('/products');

      if (response.statusCode != 200) {
        return [];
      }

      final data = response.data;
      if (data is! Map || data['success'] != true) {
        return [];
      }

      final productsList = data['data'] as List? ?? [];
      return productsList
          .whereType<Map>()
          .map((p) => Product.fromMap(p.cast<String, dynamic>()))
          .toList();
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Product?> getById(String productId) async {
    try {
      final response = await _apiClient.dio.get('/products/$productId');
      if (response.statusCode != 200) return null;

      final data = response.data;
      if (data is! Map || data['data'] is! Map) return null;

      return Product.fromMap((data['data'] as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> getByCategory(String category) async {
    try {
      final response = await _apiClient.dio.get(
        '/products',
        queryParameters: {'category': category},
      );
      if (response.statusCode != 200) return [];

      final data = response.data;
      final productsList = (data is Map ? data['data'] : null) as List? ?? [];

      return productsList
          .whereType<Map>()
          .map((p) => Product.fromMap(p.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Product>> getFeatured() async {
    try {
      final response = await _apiClient.dio.get(
        '/products',
        queryParameters: {'featured': true},
      );
      if (response.statusCode != 200) return [];

      final data = response.data;
      final productsList = (data is Map ? data['data'] : null) as List? ?? [];

      return productsList
          .whereType<Map>()
          .map((p) => Product.fromMap(p.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Product>> search(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );
      if (response.statusCode != 200) return [];

      final data = response.data;
      final productsList = (data is Map ? data['data'] : null) as List? ?? [];

      return productsList
          .whereType<Map>()
          .map((p) => Product.fromMap(p.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
