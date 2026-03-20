import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../models/product.dart';
import 'product_repository.dart';

class ProductRepoApi implements ProductRepository {
  final _apiClient = ApiClient.instance;

  @override
  Future<List<Product>> getAll() async {
    try {
      final response = await _apiClient.dio.get('/products');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch products',
        );
      }

      final data = response.data;

      if (data == null || !data.containsKey('data')) {
        throw Exception('Invalid products response');
      }

      final List<dynamic> productsList = data['data'] ?? [];

      return productsList
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('DioException fetching products: ${e.message}');
      throw Exception('Failed to fetch products: ${e.message}');
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  /// Get single product by ID
  Future<Product?> getById(String productId) async {
    try {
      final response = await _apiClient.dio.get('/products/$productId');

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data;

      if (data == null || !data.containsKey('data')) {
        return null;
      }

      return Product.fromMap(data['data'] as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Get products by category
  Future<List<Product>> getByCategory(String category) async {
    try {
      final response = await _apiClient.dio.get(
        '/products',
        queryParameters: {'category': category},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch products',
        );
      }

      final data = response.data;

      if (data == null || !data.containsKey('data')) {
        return [];
      }

      final List<dynamic> productsList = data['data'] ?? [];

      return productsList
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  /// Get featured products
  Future<List<Product>> getFeatured() async {
    try {
      final response = await _apiClient.dio.get(
        '/products',
        queryParameters: {'featured': true},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = response.data;

      if (data == null || !data.containsKey('data')) {
        return [];
      }

      final List<dynamic> productsList = data['data'] ?? [];

      return productsList
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching featured products: $e');
      return [];
    }
  }

  /// Search products
  Future<List<Product>> search(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = response.data;

      if (data == null || !data.containsKey('data')) {
        return [];
      }

      final List<dynamic> productsList = data['data'] ?? [];

      return productsList
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}