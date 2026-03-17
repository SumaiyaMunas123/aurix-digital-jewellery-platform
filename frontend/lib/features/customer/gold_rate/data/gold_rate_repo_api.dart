import 'package:dio/dio.dart';
import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';
import '../../../core/network/api_client.dart';

class GoldRateRepoApi implements GoldRateRepository {
  @override
  Future<GoldRate> getLiveRates() async {
    try {
      final res = await ApiClient.instance.dio.get('/gold-rate');
      final data = res.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to fetch gold rates');
      }

      final intl = data['international'];
      final devi = data['local_devi'];

      return GoldRate(
        xauUsd: (intl['xauUsd'] as num?)?.toDouble() ?? 0.0,
        silver: (intl['silver'] as num?)?.toDouble() ?? 0.0,
        platinum: (intl['platinum'] as num?)?.toDouble() ?? 0.0,
        lkr24k: (devi['rates']?['24k'] as num?)?.toInt() ?? 0,
        lkr22k: (devi['rates']?['22k'] as num?)?.toInt() ?? 0,
        lkr20k: (devi['rates']?['20k'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(data['fetchedAt'] ?? '') ?? DateTime.now(),
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse gold rates: $e');
    }
  }
}