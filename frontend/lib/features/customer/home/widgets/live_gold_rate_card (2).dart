import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/dev/dummy_data/dummy_gold_rates.dart';
import 'package:aurix/dev/dummy_data/dummy_gold_history.dart';

class LiveGoldRateCard extends StatelessWidget {
  const LiveGoldRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = DummyGoldRates.sriLanka;
    final intl = DummyGoldRates.international;

    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_exchange_rounded, color: AppColors.gold),
              const SizedBox(width: 10),
              const Text("Live Rates", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Spacer(),
              Text(sl["updated"] as String, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),

          const Text("Sri Lanka (LKR)", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(context, "24K (1g): ${sl["24k"]}"),
              _pill(context, "22K (1g): ${sl["22k"]}"),
              _pill(context, "20K (1g): ${sl["20k"]}"),
            ],
          ),
          const SizedBox(height: 14),

          const Text("International (USD)", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(context, "XAU/USD: ${intl["xauusd"]}"),
              _pill(context, "Silver (XAG/USD): ${intl["silver"]}"),
              _pill(context, "Platinum (XPT/USD): ${intl["platinum"]}"),
            ],
          ),
          const SizedBox(height: 14),

          const Text("Gold Trend (XAU/USD)", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          SizedBox(height: 130, child: _chart(context)),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.04 : 0.03),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _chart(BuildContext context) {
    final data = DummyGoldHistory.xauUsdHistory;
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minY: data.reduce((a, b) => a < b ? a : b) - 8,
        maxY: data.reduce((a, b) => a > b ? a : b) + 8,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: AppColors.gold,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.gold.withOpacity(isDark ? 0.12 : 0.10),
            ),
          ),
        ],
      ),
    );
  }
}