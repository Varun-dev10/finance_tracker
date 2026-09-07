import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
// groups your raw transaction list by day, sums same-day expenses,
// plots the last 14 days as a smooth line with a soft purple fill underneath

// Shows expense spending over time as a line graph.
// transactions = list of {date, amount, type} - we only plot 'expense' type here.
class SpendingTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const SpendingTrendChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group expenses by date, summing multiple transactions on the same day
    final Map<String, double> dailyTotals = {};
    for (final tx in transactions) {
      if (tx['type'] != 'expense') continue;
      final date = tx['transaction_date'] as String;
      final amount = double.parse(tx['amount'].toString());
      dailyTotals[date] = (dailyTotals[date] ?? 0) + amount;
    }

    if (dailyTotals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No spending data yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final sortedDates = dailyTotals.keys.toList()..sort();
    // Only show the most recent 14 days of activity, so the line doesn't get too cramped
    final recentDates = sortedDates.length > 14
        ? sortedDates.sublist(sortedDates.length - 14)
        : sortedDates;

    final spots = recentDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      return FlSpot(index.toDouble(), dailyTotals[date]!);
    }).toList();

    final maxY = dailyTotals.values.fold<double>(
      0,
      (max, v) => v > max ? v : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightPurple, width: 1.2),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (recentDates.length / 4).ceilToDouble().clamp(
                    1,
                    double.infinity,
                  ),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= recentDates.length)
                      return const SizedBox();
                    final parts = recentDates[index].split('-');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${parts[2]}/${parts[1]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),

            // both tooltips now use solid purple background with bold white text,
            // so the amount is clearly readable when held
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => AppColors.primaryPurple,
                getTooltipItems: (spots) => spots.map((spot) {
                  return LineTooltipItem(
                    '₹${spot.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primaryPurple,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
