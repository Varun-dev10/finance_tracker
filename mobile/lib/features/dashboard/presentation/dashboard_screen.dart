

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/stat_chip.dart';
import '../../../shared/widgets/transaction_row.dart';
import '../../../core/constants/category_icons.dart';
import '../../../core/network/category_service.dart';
import '../../transactions/data/transaction_service.dart';
import '../data/dashboard_service.dart';
import '../../../shared/widgets/category_donut_chart.dart';
import '../../../shared/widgets/chart_carousel.dart';


// The main screen of the app - shows balance, income/expense, and recent transactions.
// For now uses hardcoded sample data. Real API data comes in a later phase.
// dashboard now calls /dashboard/summary for the numbers,
// reuses the existing TransactionService and DashboardService widgets,
// to get recent transactions, sorts by newest first and shows only 5
// same reused widgets, just real data flowing in now instead of hardcoded values


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardService = DashboardService();
  final _transactionService = TransactionService();


  final _categoryService = CategoryService();
  List<Map<String, dynamic>> _categoryBreakdown = [];
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _rawTransactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  double _balance = 0;
  double _income = 0;
  double _expenses = 0;

  double _budgetAmount = 0;
  List _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _dashboardService.getSummary();
      final categoryBreakdown = await _dashboardService.getCategoryBreakdown();
      final monthlyData = await _dashboardService.getMonthly();
      final rawTxResponse = await _dashboardService.getRawTransactions();
      final budget = await _dashboardService.getBudget();

      final categories = await _categoryService.getCategories();
      final categoryMap = {
        for (var c in categories) c['id'] as String: c['name'] as String
      };
      final transactions = await _transactionService.getTransactions(categoryMap);

      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      setState(() {
        _balance = (summary['balance'] as num).toDouble();
        _income = (summary['income'] as num).toDouble();
        _expenses = (summary['expenses'] as num).toDouble();
        _categoryBreakdown = categoryBreakdown;
        _recentTransactions = transactions.take(5).toList();
        _isLoading = false;
        _monthlyData = monthlyData;
        _rawTransactions = rawTxResponse;
        _budgetAmount = double.parse(budget['amount'].toString());
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load your dashboard. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Small inline hint showing how spending compares to the budget.
  Widget _buildBudgetHint() {
    final remaining = _budgetAmount - _expenses;
    final isOverBudget = remaining < 0;
    final percentUsed = (_expenses / _budgetAmount * 100).clamp(0, 999).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isOverBudget ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOverBudget ? Icons.trending_up : Icons.check_circle_outline,
            color: isOverBudget ? AppColors.error : AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOverBudget
                  ? 'You\'ve gone ₹${remaining.abs().toStringAsFixed(0)} over your budget'
                  : 'You\'ve used $percentUsed% of your budget this month',
              style: TextStyle(
                fontSize: 13,
                color: isOverBudget ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, Varun';
    if (hour < 17) return 'Good afternoon, Varun';
    return 'Good evening, Varun';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),

                BalanceCard(balance: _balance),
                const SizedBox(height: 16),

                Row(
                  children: [
                    StatChip(
                      label: 'Income',
                      amount: _income,
                      icon: Iconsax.arrow_down_1,
                      iconColor: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    StatChip(
                      label: 'Expenses',
                      amount: _expenses,
                      icon: Iconsax.arrow_up_2,
                      iconColor: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Text('Spending by category', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                CategoryDonutChart(data: _categoryBreakdown),

                if (_budgetAmount > 0) ...[
                  const SizedBox(height: 16),
                  _buildBudgetHint(),
                ],

                const SizedBox(height: 28),

                Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ChartCarousel(monthlyData: _monthlyData, transactions: _rawTransactions),
                const SizedBox(height: 28),


                Text('Recent transactions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),

                if (_recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ..._recentTransactions.map((tx) => TransactionRow(
                    categoryName: tx.categoryName,
                    description: tx.description,
                    amount: tx.amount,
                    isIncome: tx.type == 'income',
                    icon: CategoryIcons.getIcon(tx.categoryName),
                    iconColor: CategoryIcons.getColor(tx.categoryName),
                    date: tx.transactionDate,
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}