import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_glass_card.dart';
import '../../gold_rate/data/gold_rate_repository.dart';

class LiveGoldRateCard extends StatefulWidget {
  const LiveGoldRateCard({super.key});

  @override
  State<LiveGoldRateCard> createState() => _LiveGoldRateCardState();
}

class _LiveGoldRateCardState extends State<LiveGoldRateCard> {
  final PageController _pageController = PageController(viewportFraction: 1.0);

  int _pageIndex = 0;
  String _currency = 'USD';
  bool _isLoading = true;

  List<_MetalRateData> _metals = [
    const _MetalRateData(
      name: 'Gold',
      symbol: 'XAU',
      usdPrice: 0,
      lkrPrice: 0,
      changePercent: 0,
      graph: [1940, 1965, 1988, 1972, 2005, 2032, 2024, 2048],
    ),
    const _MetalRateData(
      name: 'Silver',
      symbol: 'XAG',
      usdPrice: 0,
      lkrPrice: 0,
      changePercent: 0,
      graph: [22.8, 23.0, 23.4, 23.1, 23.6, 23.9, 24.0, 24.12],
    ),
    const _MetalRateData(
      name: 'Platinum',
      symbol: 'XPT',
      usdPrice: 0,
      lkrPrice: 0,
      changePercent: 0,
      graph: [905, 910, 918, 921, 916, 914, 909, 912.6],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<GoldRateRepository>(context, listen: false);
      final rates = await repo.getLiveRates();
      setState(() {
        _metals = [
          _MetalRateData(
            name: 'Gold',
            symbol: 'XAU',
            usdPrice: rates.xauUsd,
            lkrPrice: rates.lkr24k > 0 ? rates.lkr24k.toDouble() : rates.xauUsd * 300 / 31.103, // dummy fallback lkr 
            changePercent: 0.45,
            graph: [1940, 1965, rates.xauUsd * 0.98, rates.xauUsd * 0.99, rates.xauUsd],
          ),
          _MetalRateData(
            name: 'Silver',
            symbol: 'XAG',
            usdPrice: rates.silver,
            lkrPrice: rates.silver * 300 / 31.103, // fallback lkr conversion
            changePercent: 0.12,
            graph: [22.8, 23.0, rates.silver * 0.98, rates.silver * 0.99, rates.silver],
          ),
          _MetalRateData(
            name: 'Platinum',
            symbol: 'XPT',
            usdPrice: rates.platinum,
            lkrPrice: rates.platinum * 300 / 31.103, // fallback lkr conversion
            changePercent: -0.05,
            graph: [905, 910, rates.platinum * 1.02, rates.platinum * 1.01, rates.platinum],
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Live Market Rates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              icon: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))
                : const Icon(Icons.refresh, color: AppColors.gold, size: 20),
              onPressed: _isLoading ? null : _fetchRates,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _metals.length,
            onPageChanged: (value) {
              setState(() => _pageIndex = value);
            },
            itemBuilder: (context, index) {
              final metal = _metals[index];
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: AurixGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.gold.withValues(alpha: 0.16),
                            child: Text(
                              metal.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metal.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${metal.symbol}/USD',
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _changeChip(metal.changePercent),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '\$${metal.usdPrice.toStringAsFixed(2)} / troy ounce',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Updated ${DateFormat('dd MMM yyyy').format(now)} • ${DateFormat('hh:mm a').format(now)}',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _lineChart(
                          graph: metal.graph,
                          isPositive: metal.changePercent >= 0,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _metals.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _pageIndex == i ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: _pageIndex == i
                                  ? AppColors.gold
                                  : AppColors.gold.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _changeChip(double change) {
    final positive = change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: positive
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        border: Border.all(
          color: positive
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: positive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _lineChart({
    required List<double> graph,
    required bool isPositive,
  }) {
    final spots = <FlSpot>[];
    for (int i = 0; i < graph.length; i++) {
      spots.add(FlSpot(i.toDouble(), graph[i]));
    }

    final minY = graph.reduce((a, b) => a < b ? a : b);
    final maxY = graph.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.18 == 0 ? 1.0 : (maxY - minY) * 0.18;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3.6,
            color: isPositive ? AppColors.gold : Colors.redAccent,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (isPositive ? AppColors.gold : Colors.redAccent)
                  .withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLkr(double value) {
    return NumberFormat('#,##0.00').format(value);
  }
}

class _MetalRateData {
  final String name;
  final String symbol;
  final double usdPrice;
  final double lkrPrice;
  final double changePercent;
  final List<double> graph;

  const _MetalRateData({
    required this.name,
    required this.symbol,
    required this.usdPrice,
    required this.lkrPrice,
    required this.changePercent,
    required this.graph,
  });
}