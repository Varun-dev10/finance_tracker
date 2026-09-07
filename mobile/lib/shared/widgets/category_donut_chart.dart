import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/category_icons.dart';
import '../../core/theme/app_theme.dart';

// Shows a donut chart of spending broken down by category,
// with the total amount displayed in the center of the donut hole.
class CategoryDonutChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const CategoryDonutChart({super.key, required this.data});

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1; // tracks which slice the user tapped, -1 = none

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No spending data yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final total = widget.data.fold<double>(0, (sum, item) => sum + (item['total'] as num));

    // If a slice is tapped, show that category's amount in the center instead of the total
    final centerLabel = _touchedIndex >= 0
        ? widget.data[_touchedIndex]['category'] as String
        : 'Total Spent';
    final centerValue = _touchedIndex >= 0
        ? (widget.data[_touchedIndex]['total'] as num).toDouble()
        : total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightPurple, width: 1.2),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: widget.data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final categoryName = item['category'] as String;
                      final amount = (item['total'] as num).toDouble();
                      final isTouched = index == _touchedIndex;

                      return PieChartSectionData(
                        value: amount,
                        color: CategoryIcons.getColor(categoryName),
                        // Slice grows slightly when tapped - subtle interactive feel
                        radius: isTouched ? 55 : 48,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Center text overlay - total (or tapped category) amount
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(centerLabel, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '₹${centerValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Legend - each item shows a colored dot, category name, and percentage
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: widget.data.map((item) {
              final categoryName = item['category'] as String;
              final amount = (item['total'] as num).toDouble();
              final percent = (amount / total * 100).toStringAsFixed(0);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: CategoryIcons.getColor(categoryName),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$categoryName  $percent%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}