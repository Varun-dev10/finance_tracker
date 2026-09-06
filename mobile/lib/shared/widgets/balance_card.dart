import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// The big purple card at the top of the dashboard.
// Shows current balance with a gradient background and a subtle count-up animation.
// reusable for both Income and Expense, just pass different label/icon/color,
// avoids writing the same widget twice
class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Gradient from light purple to dark purple, gives it depth instead of flat color
        gradient: const LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.darkPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // TweenAnimationBuilder animates the number counting up from 0
          // to the real balance when the screen first loads.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: balance),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Text(
                '₹${value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}