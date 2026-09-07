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
  final DateTime date;

  const TransactionRow({
    super.key,
    required this.categoryName,
    this.description,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // If there's no description, fall back to showing the category as the main text
    final hasDescription = description != null && description!.isNotEmpty;
    final mainText = hasDescription ? description! : categoryName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightPurple, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description is now the main, bold text
                Text(
                  mainText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Category + date shown together as small secondary text
                Text(
                  hasDescription
                      ? '$categoryName • ${_formatDate(date)}'
                      : _formatDate(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
