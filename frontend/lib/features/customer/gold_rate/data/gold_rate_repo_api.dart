import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoApi implements GoldRateRepository {
  @override
  Future<GoldRate> getLiveRates() async {
    // TODO: connect backend
    return GoldRate(
      xauUsd: 0,
      silver: 0,
      platinum: 0,
      lkr24k: 0,
      lkr22k: 0,
      lkr20k: 0,
      updatedAt: DateTime.now(),
    );
  }
}