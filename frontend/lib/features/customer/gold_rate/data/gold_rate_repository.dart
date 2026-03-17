import '../models/gold_rate.dart';

abstract class GoldRateRepository {
  Future<GoldRate> getLiveRates();
}