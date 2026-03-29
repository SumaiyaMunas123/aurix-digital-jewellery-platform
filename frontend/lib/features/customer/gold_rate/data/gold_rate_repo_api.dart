import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoApi implements GoldRateRepository {
  static const String _baseUrl = 'http://localhost:6001/gold-rate';

  @override
  Future<GoldRate> getLiveRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Gold rate service timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final intl = jsonData['international'] ?? {};
          final local = jsonData['local_devi'] ?? {};

          return GoldRate(
            xauUsd: (intl['xauUsd'] ?? 0).toDouble(),
            silver: (intl['silver'] ?? 0).toDouble(),
            platinum: (intl['platinum'] ?? 0).toDouble(),
            lkr24k: local['lkr24k'] ?? 0,
            lkr22k: local['lkr22k'] ?? 0,
            lkr20k: local['lkr20k'] ?? 0,
            updatedAt: DateTime.tryParse(intl['timestamp'] ?? jsonData['fetchedAt'] ?? '') ?? DateTime.now(),
          );
        }
      }

      throw Exception('Failed to fetch gold rates');
    } catch (e) {
      print('Gold rate API error: $e');
      rethrow;
    }
  }
}