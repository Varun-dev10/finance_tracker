import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/budget_service.dart';
import '../../dashboard/data/dashboard_service.dart';

// gradient card flips to red when over budget,
// progress bar visualizes spent/budget ratio,
// reuses the existing DashboardService.getSummary()
// to get real "spent" amount — no duplicate logic

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetService = BudgetService();
  final _dashboardService = DashboardService();
  final _amountController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  double _budgetAmount = 0;
  double _spent = 0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final budget = await _budgetService.getBudget(now);
      final summary = await _dashboardService.getSummary();

      setState(() {
        _budgetAmount = double.parse(budget['amount'].toString());
        _spent = (summary['expenses'] as num).toDouble();
        _isLoading = false;
        // Pre-fill the input with the current budget so editing doesn't mean starting from scratch
        if (_budgetAmount > 0) {
          _amountController.text = _budgetAmount.toStringAsFixed(0);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _budgetService.setBudget(DateTime.now(), amount);
      await _loadBudget();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save budget. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  } @override
  Widget build(BuildContext context) {
    final remaining = _budgetAmount - _spent;
    final isOverBudget = remaining < 0;
    final progress = _budgetAmount > 0 ? (_spent / _budgetAmount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                if (_budgetAmount == 0)
                // No budget set yet - empty state
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('No budget set yet', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(
                          'Set a monthly budget to track how your spending compares.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOverBudget
                            ? [AppColors.error, const Color(0xFF8E1B1B)]
                            : [AppColors.primaryPurple, AppColors.darkPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverBudget ? 'Over budget by' : 'Remaining',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${remaining.abs().toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        // Progress bar - shows spent vs budget visually
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Spent ₹${_spent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            Text('Budget ₹${_budgetAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),
                Text('Set monthly budget', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBudget,
                    child: _isSaving
                        ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Save Budget'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}