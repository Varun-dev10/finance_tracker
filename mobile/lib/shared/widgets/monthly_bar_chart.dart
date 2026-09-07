import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

//groups your /dashboard/monthly data (which comes as separate income/expense rows)
// into paired bars per month — green bar = income, red = expense, side by side

// Shows income vs expense as grouped bars, one pair per month.
// data = list of {"month": "2026-09-01", "type": "income"/"expense", "total": 45000.0}
class MonthlyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No data yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    // Group the flat list into { "2026-09": {income: x, expense: y} }
    final Map<String, Map<String, double>> grouped = {};
    for (final item in data) {
      final month = (item['month'] as String).substring(0, 7); // "2026-09"
      final type = item['type'] as String;
      final total = (item['total'] as num).toDouble();
      grouped.putIfAbsent(month, () => {'income': 0, 'expense': 0});
      grouped[month]![type] = total;
    }

    final months = grouped.keys.toList()..sort();
    final maxValue = grouped.values
        .expand((m) => [m['income']!, m['expense']!])
        .fold<double>(0, (max, v) => v > max ? v : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightPurple, width: 1.2),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) return const SizedBox();
                        final monthLabel = _formatMonth(months[index]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(monthLabel, style: Theme.of(context).textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: months.asMap().entries.map((entry) {
                  final index = entry.key;
                  final month = entry.value;
                  final income = grouped[month]!['income']!;
                  final expense = grouped[month]!['expense']!;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: AppColors.success,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: expense,
                        color: AppColors.error,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    barsSpace: 6,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Simple legend for income/expense colors
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.success, 'Income'),
              const SizedBox(width: 20),
              _legendDot(AppColors.error, 'Expense'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  String _formatMonth(String yyyymm) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final parts = yyyymm.split('-');
    return months[int.parse(parts[1]) - 1];
  }
}