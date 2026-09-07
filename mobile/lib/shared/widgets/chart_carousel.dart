import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'monthly_bar_chart.dart';
import 'spending_trend_chart.dart';

// PageView = the swipeable container,
// AnimatedContainer for the dots gives a smooth pill-shaped active indicator (widens when active)

// A horizontally swipeable pair of charts: monthly overview first, then spending trend.
// Dots below show which page you're on.
class ChartCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyData;
  final List<Map<String, dynamic>> transactions;

  const ChartCarousel({
    super.key,
    required this.monthlyData,
    required this.transactions,
  });

  @override
  State<ChartCarousel> createState() => _ChartCarouselState();
}

class _ChartCarouselState extends State<ChartCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _titles = ['Monthly overview', 'Spending trend'];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _titles[_currentPage],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280, // fits the chart card + legend/labels
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              MonthlyBarChart(data: widget.monthlyData),
              SpendingTrendChart(transactions: widget.transactions),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Two small dots - filled one shows current page
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryPurple
                    : AppColors.lightPurple,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
