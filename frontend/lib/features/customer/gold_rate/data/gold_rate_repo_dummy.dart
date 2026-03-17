import 'package:aurix/dev/dummy_data/dummy_gold_rates.dart';
import '../models/gold_rate.dart';
import 'gold_rate_repository.dart';

class GoldRateRepoDummy implements GoldRateRepository {
  @override
  Future<GoldRate> getLiveRates() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final sl = DummyGoldRates.sriLanka;
    final intl = DummyGoldRates.international;

    return GoldRate(
      xauUsd: (intl["xauusd"] as num).toDouble(),
      silver: (intl["silver"] as num).toDouble(),
      platinum: (intl["platinum"] as num).toDouble(),
      lkr24k: (sl["24k"] as num).toInt(),
      lkr22k: (sl["22k"] as num).toInt(),
      lkr20k: (sl["20k"] as num).toInt(),
      updatedAt: DateTime.now(),
    );
  }
}