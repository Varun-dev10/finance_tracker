import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
//isIncome flips both the +/- sign and the color (green/red) of the amount.
// one variable driving two visual changes, avoids duplicating logic.

// One row in the "Recent transactions" list.
// Shows a category icon, name/description, and the amount
// (green for income, red for expense).
class TransactionRow extends StatelessWidget {
  final String categoryName;
  final String? description;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;

  const TransactionRow({
    super.key,
    required this.categoryName,
    this.description,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Icon in a soft colored circle - same pattern as the stat chips,
          // keeps the whole app visually consistent.
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoryName, style: Theme.of(context).textTheme.bodyMedium),
                if (description != null && description!.isNotEmpty)
                  Text(description!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isIncome ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}