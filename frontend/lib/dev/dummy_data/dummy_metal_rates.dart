import 'dart:math';

enum MetalType { gold, silver, platinum }
enum MetalUnit { gram, pawn, ounce, kilogram }
enum MetalCurrency { usd }
enum MetalRange { day1, day7, month1 }

class MetalHistoryPoint {
  final DateTime time;
  final double usdPerOunce;

  const MetalHistoryPoint({
    required this.time,
    required this.usdPerOunce,
  });
}

class MetalSnapshot {
  final MetalType metal;
  final String label;
  final List<MetalHistoryPoint> oneDay;
  final List<MetalHistoryPoint> sevenDays;
  final List<MetalHistoryPoint> oneMonth;

  const MetalSnapshot({
    required this.metal,
    required this.label,
    required this.oneDay,
    required this.sevenDays,
    required this.oneMonth,
  });

  List<MetalHistoryPoint> pointsFor(MetalRange range) {
    switch (range) {
      case MetalRange.day1:
        return oneDay;
      case MetalRange.day7:
        return sevenDays;
      case MetalRange.month1:
        return oneMonth;
    }
  }
}

class DummyMetalRates {
  static const double gramsPerOunce = 31.1034768;
  static const double gramsPerPawn = 8.0;
  static const double gramsPerKilogram = 1000.0;

  static final List<MetalSnapshot> metals = [
    MetalSnapshot(
      metal: MetalType.gold,
      label: 'Gold',
      oneDay: _generateSeries(
        base: 2340.10,
        count: 12,
        stepHours: 1,
        volatility: 16,
      ),
      sevenDays: _generateSeries(
        base: 2322.0,
        count: 7,
        stepHours: 24,
        volatility: 30,
      ),
      oneMonth: _generateSeries(
        base: 2280.0,
        count: 30,
        stepHours: 24,
        volatility: 50,
      ),
    ),
    MetalSnapshot(
      metal: MetalType.silver,
      label: 'Silver',
      oneDay: _generateSeries(
        base: 27.85,
        count: 12,
        stepHours: 1,
        volatility: 0.5,
      ),
      sevenDays: _generateSeries(
        base: 27.20,
        count: 7,
        stepHours: 24,
        volatility: 0.9,
      ),
      oneMonth: _generateSeries(
        base: 26.40,
        count: 30,
        stepHours: 24,
        volatility: 1.6,
      ),
    ),
    MetalSnapshot(
      metal: MetalType.platinum,
      label: 'Platinum',
      oneDay: _generateSeries(
        base: 980.40,
        count: 12,
        stepHours: 1,
        volatility: 10,
      ),
      sevenDays: _generateSeries(
        base: 965.0,
        count: 7,
        stepHours: 24,
        volatility: 22,
      ),
      oneMonth: _generateSeries(
        base: 930.0,
        count: 30,
        stepHours: 24,
        volatility: 36,
      ),
    ),
  ];

  static List<MetalHistoryPoint> _generateSeries({
    required double base,
    required int count,
    required int stepHours,
    required double volatility,
  }) {
    final now = DateTime.now();
    final random = Random(base.toInt() + count);
    final List<MetalHistoryPoint> points = [];
    double current = base;

    for (int i = count - 1; i >= 0; i--) {
      final drift = (random.nextDouble() - 0.5) * volatility;
      current = max(0.01, current + drift);

      points.add(
        MetalHistoryPoint(
          time: now.subtract(Duration(hours: i * stepHours)),
          usdPerOunce: double.parse(current.toStringAsFixed(2)),
        ),
      );
    }

    return points;
  }

  static String formatUnitLabel(MetalUnit unit) {
    switch (unit) {
      case MetalUnit.gram:
        return 'g';
      case MetalUnit.pawn:
        return 'pawn';
      case MetalUnit.ounce:
        return 'oz';
      case MetalUnit.kilogram:
        return 'kg';
    }
  }

  static double convertUsdPerOunce(
    double usdPerOunce,
    MetalUnit unit,
    MetalCurrency currency,
  ) {
    switch (unit) {
      case MetalUnit.ounce:
        return usdPerOunce;
      case MetalUnit.gram:
        return usdPerOunce / gramsPerOunce;
      case MetalUnit.pawn:
        return (usdPerOunce / gramsPerOunce) * gramsPerPawn;
      case MetalUnit.kilogram:
        return (usdPerOunce / gramsPerOunce) * gramsPerKilogram;
    }
  }

  static String formatPrice(
    double usdPerOunce,
    MetalUnit unit,
    MetalCurrency currency,
  ) {
    final value = convertUsdPerOunce(usdPerOunce, unit, currency);
    return 'USD ${value.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String formatTimeWithSeconds(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $suffix';
  }
}