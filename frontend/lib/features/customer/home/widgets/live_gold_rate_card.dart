import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_glass_card.dart';

class LiveGoldRateCard extends StatefulWidget {
  const LiveGoldRateCard({super.key});

  @override
  State<LiveGoldRateCard> createState() => _LiveGoldRateCardState();
}

class _LiveGoldRateCardState extends State<LiveGoldRateCard> {
  final PageController _pageController = PageController(viewportFraction: 1.0);

  int _pageIndex = 0;
  String _currency = 'USD';

  final List<_MetalRateData> _metals = const [
    _MetalRateData(
      name: 'Gold',
      symbol: 'XAU',
      usdPrice: 2048.25,
      lkrPrice: 618540.00,
      changePercent: 1.24,
      graph: [1940, 1965, 1988, 1972, 2005, 2032, 2024, 2048],
    ),
    _MetalRateData(
      name: 'Silver',
      symbol: 'XAG',
      usdPrice: 24.12,
      lkrPrice: 7288.00,
      changePercent: 0.86,
      graph: [22.8, 23.0, 23.4, 23.1, 23.6, 23.9, 24.0, 24.12],
    ),
    _MetalRateData(
      name: 'Platinum',
      symbol: 'XPT',
      usdPrice: 912.60,
      lkrPrice: 275510.00,
      changePercent: -0.34,
      graph: [905, 910, 918, 921, 916, 914, 909, 912.6],
    ),
  ];

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
            _currencyToggle(),
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
                                  _currency == 'USD'
                                      ? '${metal.symbol}/USD'
                                      : '${metal.symbol}/LKR',
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
                        _currency == 'USD'
                            ? '\$${metal.usdPrice.toStringAsFixed(2)}'
                            : 'LKR ${_formatLkr(metal.lkrPrice)}',
                        style: const TextStyle(
                          fontSize: 30,
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

  Widget _currencyToggle() {
    final isUsd = _currency == 'USD';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(
            label: 'USD',
            selected: isUsd,
            onTap: () => setState(() => _currency = 'USD'),
          ),
          _toggleButton(
            label: 'LKR',
            selected: !isUsd,
            onTap: () => setState(() => _currency = 'LKR'),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? AppColors.gold : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected ? Colors.black : null,
          ),
        ),
      ),
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