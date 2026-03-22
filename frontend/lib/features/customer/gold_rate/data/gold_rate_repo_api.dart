import 'package:dio/dio.dart';
import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoApi implements GoldRateRepository {
  static const String _baseUrl = 'http://localhost:6000/gold-rate';
  final _dio = Dio();

  @override
  Future<GoldRate> getLiveRates() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];

          return GoldRate(
            xauUsd: (data['xauUsd'] ?? 0).toDouble(),
            silver: (data['silver'] ?? 0).toDouble(),
            platinum: (data['platinum'] ?? 0).toDouble(),
            lkr24k: data['lkr24k'] ?? 0,
            lkr22k: data['lkr22k'] ?? 0,
            lkr20k: data['lkr20k'] ?? 0,
            updatedAt: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
          );
        }
      }

      throw Exception('Failed to fetch gold rates');
    } catch (e) {
      rethrow;
    }
  }
}