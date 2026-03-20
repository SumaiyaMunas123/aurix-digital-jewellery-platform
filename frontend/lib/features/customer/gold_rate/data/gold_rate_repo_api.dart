import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoApi implements GoldRateRepository {
  static const String _baseUrl = 'http://localhost:6000/gold-rate';

  @override
  Future<GoldRate> getLiveRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Gold rate service timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

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
      print('Gold rate API error: $e');
      rethrow;
    }
  }
}