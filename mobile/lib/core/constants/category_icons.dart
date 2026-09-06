import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Maps each category name to a fixed icon + color.
// This is the ONE place that decides "what does Food look like" -
// every screen (dashboard, transactions list, add transaction) uses this,
// so a category always looks the same everywhere in the app.
class CategoryIcons {
  static const Map<String, IconData> icons = {
    'Food': Iconsax.reserve,
    'Transport': Iconsax.bus,
    'Shopping': Iconsax.bag_2,
    'Entertainment': Iconsax.video_play,
    'Bills': Iconsax.receipt_2,
    'Healthcare': Iconsax.health,
    'Education': Iconsax.teacher,
    'Other': Iconsax.category,
    'Salary': Iconsax.wallet_2,
    'Freelance': Iconsax.briefcase,
    'Investment': Iconsax.trend_up,
    'Other Income': Iconsax.money_recive,
  };

  static const Map<String, Color> colors = {
    'Food': Color(0xFFFF7043),
    'Transport': Color(0xFF42A5F5),
    'Shopping': Color(0xFFEC407A),
    'Entertainment': Color(0xFFAB47BC),
    'Bills': Color(0xFF78909C),
    'Healthcare': Color(0xFFEF5350),
    'Education': Color(0xFF26A69A),
    'Other': Color(0xFF8D6E63),
    'Salary': Color(0xFF66BB6A),
    'Freelance': Color(0xFF29B6F6),
    'Investment': Color(0xFF9CCC65),
    'Other Income': Color(0xFFFFCA28),
  };

  static IconData getIcon(String category) => icons[category] ?? Iconsax.category;
  static Color getColor(String category) => colors[category] ?? Colors.grey;
}