class GoldRate {
  final double xauUsd;
  final double silver;
  final double platinum;

  final int lkr24k;
  final int lkr22k;
  final int lkr20k;

  final DateTime updatedAt;

  const GoldRate({
    required this.xauUsd,
    required this.silver,
    required this.platinum,
    required this.lkr24k,
    required this.lkr22k,
    required this.lkr20k,
    required this.updatedAt,
  });
}