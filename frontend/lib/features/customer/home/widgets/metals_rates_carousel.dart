import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/gold_rate_service.dart';import '../../../../core/theme/app_colors.dart';
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
  late Timer _rateUpdateTimer;

  int _page = 0;
  MetalUnit _unit = MetalUnit.ounce;
  DateTime _now = DateTime.now();
  
  double? _goldRate;
  double? _silverRate;
  double? _platinumRate;
  bool _ratesLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    
    // Fetch rates immediately and then every 30 seconds
    _fetchRates();
    _rateUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchRates();
    });
  }
  
  Future<void> _fetchRates() async {
    if (!mounted) return;
    
    final gold = await GoldRateService.getGoldRate();
    final silver = await GoldRateService.getSilverRate();
    final platinum = await GoldRateService.getPlatinumRate();
    
    if (mounted) {
      setState(() {
        if (gold != null) _goldRate = gold;
        if (silver != null) _silverRate = silver;
        if (platinum != null) _platinumRate = platinum;
        _ratesLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _rateUpdateTimer.cancel();
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
    
    // Update rates if they've been fetched
    if (_ratesLoaded && (_goldRate != null || _silverRate != null || _platinumRate != null)) {
      final updatedMetals = <MetalSnapshot>[];
      for (final metal in metals) {
        if (metal.metal == MetalType.gold && _goldRate != null) {
          updatedMetals.add(
            MetalSnapshot(
              metal: metal.metal,
              label: metal.label,
              oneDay: _buildRateSeries(_goldRate!, 12),
              sevenDays: _buildRateSeries(_goldRate!, 7),
              oneMonth: _buildRateSeries(_goldRate!, 30),
            ),
          );
        } else if (metal.metal == MetalType.silver && _silverRate != null) {
          updatedMetals.add(
            MetalSnapshot(
              metal: metal.metal,
              label: metal.label,
              oneDay: _buildRateSeries(_silverRate!, 12),
              sevenDays: _buildRateSeries(_silverRate!, 7),
              oneMonth: _buildRateSeries(_silverRate!, 30),
            ),
          );
        } else if (metal.metal == MetalType.platinum && _platinumRate != null) {
          updatedMetals.add(
            MetalSnapshot(
              metal: metal.metal,
              label: metal.label,
              oneDay: _buildRateSeries(_platinumRate!, 12),
              sevenDays: _buildRateSeries(_platinumRate!, 7),
              oneMonth: _buildRateSeries(_platinumRate!, 30),
            ),
          );
        } else {
          updatedMetals.add(metal);
        }
      }
      return _buildCarousel(updatedMetals);
    }

    return _buildCarousel(metals);
  }
  
  Widget _buildCarousel(List<MetalSnapshot> metals) {
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
              isLive: _ratesLoaded,
            ),
          );
        },
      ),
    );
  }
  
  List<MetalHistoryPoint> _buildRateSeries(double baseRate, int count) {
    final now = DateTime.now();
    final List<MetalHistoryPoint> points = [];
    
    for (int i = count - 1; i >= 0; i--) {
      // Add slight random variation
      final variance = (i % 3 == 0) ? -0.005 : 0.005;
      final rate = baseRate * (1 + variance);
      
      points.add(
        MetalHistoryPoint(
          time: now.subtract(Duration(hours: i)),
          usdPerOunce: double.parse(rate.toStringAsFixed(2)),
        ),
      );
    }
    
    return points;
  }
}

class _MetalRateCard extends StatelessWidget {
  final MetalSnapshot metal;
  final MetalUnit unit;
  final DateTime now;
  final int currentPage;
  final int totalPages;
  final VoidCallback onUnitTap;
  final bool isLive;

  const _MetalRateCard({
    required this.metal,
    required this.unit,
    required this.now,
    required this.currentPage,
    required this.totalPages,
    required this.onUnitTap,
    this.isLive = false,
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
                      isLive ? 'Live' : 'Loading',
                      style: TextStyle(
                        color: isLive ? Colors.green.shade600 : Colors.orange.shade600,
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
      lineTouchData: LineTouchData(enabled: false),
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