import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_background.dart';
import '../../../../core/widgets/aurix_glass_card.dart';
import '../../../../dev/dummy_data/dummy_metal_rates.dart';

class MetalDetailScreen extends StatefulWidget {
  final MetalSnapshot metal;
  final MetalUnit initialUnit;

  const MetalDetailScreen({
    super.key,
    required this.metal,
    this.initialUnit = MetalUnit.ounce,
  });

  @override
  State<MetalDetailScreen> createState() => _MetalDetailScreenState();
}

class _MetalDetailScreenState extends State<MetalDetailScreen> {
  late MetalUnit _unit;
  late Timer _timer;

  DateTime _now = DateTime.now();
  MetalRange _range = MetalRange.day1;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _codeLabel() {
    switch (widget.metal.metal) {
      case MetalType.gold:
        return 'XAU/USD';
      case MetalType.silver:
        return 'XAG/USD';
      case MetalType.platinum:
        return 'XPT/USD';
    }
  }

  String _rangeLabel() {
    switch (_range) {
      case MetalRange.day1:
        return '1D';
      case MetalRange.day7:
        return '7D';
      case MetalRange.month1:
        return '1M';
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.metal.pointsFor(_range);
    final latest = points.last;
    final first = points.first;

    final currentValue = DummyMetalRates.convertUsdPerOunce(
      latest.usdPerOunce,
      _unit,
      MetalCurrency.usd,
    );
    final firstValue = DummyMetalRates.convertUsdPerOunce(
      first.usdPerOunce,
      _unit,
      MetalCurrency.usd,
    );

    final delta = currentValue - firstValue;
    final deltaPercent = firstValue == 0 ? 0 : (delta / firstValue) * 100;
    final isUp = delta >= 0;

    final high = points
        .map((e) => e.usdPerOunce)
        .reduce((a, b) => a > b ? a : b);
    final low = points
        .map((e) => e.usdPerOunce)
        .reduce((a, b) => a < b ? a : b);

    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.metal.label} Rate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),

              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.metal.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DummyMetalRates.formatPrice(
                        latest.usdPerOunce,
                        _unit,
                        MetalCurrency.usd,
                      ),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_codeLabel()}  •  ${DummyMetalRates.formatUnitLabel(_unit)}',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${isUp ? '+' : ''}${delta.toStringAsFixed(2)} USD',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isUp ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '(${isUp ? '+' : ''}${deltaPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isUp ? Colors.green : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: LineChart(_buildChart(points)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Range',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<MetalRange>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: MetalRange.day1,
                          label: Text('1D'),
                        ),
                        ButtonSegment(
                          value: MetalRange.day7,
                          label: Text('7D'),
                        ),
                        ButtonSegment(
                          value: MetalRange.month1,
                          label: Text('1M'),
                        ),
                      ],
                      selected: {_range},
                      onSelectionChanged: (value) {
                        setState(() => _range = value.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                            AppColors.gold.withOpacity(0.18),
                        selectedForegroundColor: AppColors.gold,
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.25),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Weight',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<MetalUnit>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: MetalUnit.ounce,
                          label: Text('oz'),
                        ),
                        ButtonSegment(
                          value: MetalUnit.gram,
                          label: Text('g'),
                        ),
                        ButtonSegment(
                          value: MetalUnit.pawn,
                          label: Text('pawn'),
                        ),
                        ButtonSegment(
                          value: MetalUnit.kilogram,
                          label: Text('kg'),
                        ),
                      ],
                      selected: {_unit},
                      onSelectionChanged: (value) {
                        setState(() => _unit = value.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                            AppColors.gold.withOpacity(0.18),
                        selectedForegroundColor: AppColors.gold,
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.25),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Market Snapshot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _row('Date', DummyMetalRates.formatDate(_now)),
                    _row('Live Time', DummyMetalRates.formatTimeWithSeconds(_now)),
                    _row('Code', _codeLabel()),
                    _row('Range', _rangeLabel()),
                    _row('Weight', DummyMetalRates.formatUnitLabel(_unit)),
                    _row(
                      'High',
                      DummyMetalRates.formatPrice(
                        high,
                        _unit,
                        MetalCurrency.usd,
                      ),
                    ),
                    _row(
                      'Low',
                      DummyMetalRates.formatPrice(
                        low,
                        _unit,
                        MetalCurrency.usd,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.metal.label} spot prices are shown in USD and converted by the selected weight unit. Historical points here are demo data for frontend development.',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChart(List<MetalHistoryPoint> points) {
    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.usdPerOunce);
    }).toList();

    final minY = points
            .map((e) => e.usdPerOunce)
            .reduce((a, b) => a < b ? a : b) *
        0.98;
    final maxY = points
            .map((e) => e.usdPerOunce)
            .reduce((a, b) => a > b ? a : b) *
        1.02;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.gold.withOpacity(0.08),
          strokeWidth: 1,
        ),
      ),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.gold,
          barWidth: 3.6,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.gold.withOpacity(0.10),
          ),
        ),
      ],
    );
  }
}