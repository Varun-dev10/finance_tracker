import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/stat_chip.dart';
import '../../../shared/widgets/transaction_row.dart';
import '../../../core/constants/category_icons.dart';

// The main screen of the app - shows balance, income/expense, and recent transactions.
// For now uses hardcoded sample data. Real API data comes in a later phase.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple greeting instead of a boxy default app bar
              Text(
                'Good evening, Varun',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),

              const BalanceCard(balance: 28750),
              const SizedBox(height: 16),

              // Income and expense side by side
              Row(
                children: [
                  StatChip(
                    label: 'Income',
                    amount: 45000,
                    icon: Iconsax.arrow_down_1,
                    iconColor: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  StatChip(
                    label: 'Expenses',
                    amount: 16250,
                    icon: Iconsax.arrow_up_2,
                    iconColor: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // Sample rows - will be replaced with real transaction data later
              TransactionRow(
                categoryName: 'Food',
                description: 'Restaurant',
                amount: 450,
                isIncome: false,
                icon: CategoryIcons.getIcon('Food'),
                iconColor: CategoryIcons.getColor('Food'),
              ),
              TransactionRow(
                categoryName: 'Salary',
                description: 'September salary',
                amount: 45000,
                isIncome: true,
                icon: CategoryIcons.getIcon('Salary'),
                iconColor: CategoryIcons.getColor('Salary'),
              ),
              TransactionRow(
                categoryName: 'Transport',
                description: 'Metro',
                amount: 80,
                isIncome: false,
                icon: CategoryIcons.getIcon('Transport'),
                iconColor: CategoryIcons.getColor('Transport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}