import 'package:aurix/core/network/api_client.dart';

import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoApi implements GoldRateRepository {
  @override
  Future<GoldRate> getLiveRates() async {
    try {
      final response = await ApiClient.instance.dio.get('/gold-rate');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true) {
          final intl = data['international'] ?? {};
          final local = data['local_devi'] ?? {};
          
          return GoldRate(
            xauUsd: (intl['xauUsd'] as num?)?.toDouble() ?? 0.0,
            silver: (intl['silver'] as num?)?.toDouble() ?? 0.0,
            platinum: (intl['platinum'] as num?)?.toDouble() ?? 0.0,
            lkr24k: (local['lkr24k'] as num?)?.toInt() ?? 0,
            lkr22k: (local['lkr22k'] as num?)?.toInt() ?? 0,
            lkr20k: (local['lkr20k'] as num?)?.toInt() ?? 0,
            updatedAt: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
          );
        }
        
        return GoldRate(
          xauUsd: 0,
          silver: 0,
          platinum: 0,
          lkr24k: 0,
          lkr22k: 0,
          lkr20k: 0,
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to fetch gold rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching gold rates: $e');
      rethrow;
    }
  }
}