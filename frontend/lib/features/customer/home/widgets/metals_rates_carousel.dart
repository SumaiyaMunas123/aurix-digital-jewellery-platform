import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_glass_card.dart';
import '../../../../dev/dummy_data/dummy_metal_rates.dart';
import '../../../customer/gold_rate/pages/metal_detail_screen.dart';

class MetalsRatesCarousel extends StatefulWidget {
  const MetalsRatesCarousel({super.key});

  @override
  State<MetalsRatesCarousel> createState() => _MetalsRatesCarouselState();
}

class _MetalsRatesCarouselState extends State<MetalsRatesCarousel> {
  late final PageController _pageController;
  late Timer _timer;

  int _page = 0;
  MetalUnit _unit = MetalUnit.ounce;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _cycleUnit() {
    setState(() {
      switch (_unit) {
        case MetalUnit.ounce:
          _unit = MetalUnit.gram;
          break;
        case MetalUnit.gram:
          _unit = MetalUnit.pawn;
          break;
        case MetalUnit.pawn:
          _unit = MetalUnit.kilogram;
          break;
        case MetalUnit.kilogram:
          _unit = MetalUnit.ounce;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final metals = DummyMetalRates.metals;

    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        itemCount: metals.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          final metal = metals[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MetalDetailScreen(
                    metal: metal,
                    initialUnit: _unit,
                  ),
                ),
              );
            },
            child: _MetalRateCard(
              metal: metal,
              unit: _unit,
              now: _now,
              currentPage: _page,
              totalPages: metals.length,
              onUnitTap: _cycleUnit,
            ),
          );
        },
      ),
    );
  }
}

class _MetalRateCard extends StatelessWidget {
  final MetalSnapshot metal;
  final MetalUnit unit;
  final DateTime now;
  final int currentPage;
  final int totalPages;
  final VoidCallback onUnitTap;

  const _MetalRateCard({
    required this.metal,
    required this.unit,
    required this.now,
    required this.currentPage,
    required this.totalPages,
    required this.onUnitTap,
  });

  String _codeLabel() {
    switch (metal.metal) {
      case MetalType.gold:
        return 'XAU/USD';
      case MetalType.silver:
        return 'XAG/USD';
      case MetalType.platinum:
        return 'XPT/USD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = metal.oneDay.last;

    return AurixGlassCard(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        metal.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DummyMetalRates.formatPrice(
                    latest.usdPerOunce,
                    unit,
                    MetalCurrency.usd,
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_codeLabel()}  •  ${DummyMetalRates.formatUnitLabel(unit)}',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DummyMetalRates.formatDate(now),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      DummyMetalRates.formatTimeWithSeconds(now),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: LineChart(_chart(metal.oneDay)),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onUnitTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.gold.withValues(alpha: 0.18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      DummyMetalRates.formatUnitLabel(unit),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 6,
            bottom: 8,
            child: Row(
              children: List.generate(totalPages, (i) {
                final active = i == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(left: 6),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: active
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.25),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _chart(List<MetalHistoryPoint> points) {
    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.usdPerOunce);
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.gold,
          barWidth: 3.6,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.gold.withValues(alpha: 0.10),
          ),
        ),
      ],
      minY: points.map((e) => e.usdPerOunce).reduce((a, b) => a < b ? a : b) *
          0.98,
      maxY: points.map((e) => e.usdPerOunce).reduce((a, b) => a > b ? a : b) *
          1.02,
    );
  }
}