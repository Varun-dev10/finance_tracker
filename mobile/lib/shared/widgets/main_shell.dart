import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/budgets/presentation/budget_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

// This widget holds the bottom navigation bar and switches between
// the 4 main screens. It's a StatefulWidget because it needs to
// remember which tab is currently selected.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // One screen per tab, in the same order as the nav bar icons below.
  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens alive in memory instead of rebuilding
      // them every time the user switch tabs - so scroll position etc is preserved.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.lightPurple,
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.home_2), label: 'Home'),
          NavigationDestination(icon: Icon(Iconsax.receipt_item), label: 'Transactions'),
          NavigationDestination(icon: Icon(Iconsax.wallet_check), label: 'Budget'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
    );
  }
}