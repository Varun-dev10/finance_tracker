/* RefreshIndicator = pull-down-to-refresh (spec's UX requirement),
FloatingActionButton opens the add-transaction screen and reloads the list once user come back
this reuses the existing TransactionRow widget from the dashboard,
so styling stays consistent everywhere.*/

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/category_icons.dart';
import '../../../core/network/category_service.dart';
import '../data/transaction_service.dart';
import '../models/transaction_model.dart';
import '../../../shared/widgets/transaction_row.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _transactionService = TransactionService();
  final _categoryService = CategoryService();

  final _searchController = TextEditingController();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _allTransactions =
      []; // unfiltered, kept as source of truth
  String _searchQuery = '';
  String? _filterType; // null = all, 'income', or 'expense'
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _categoryService.getCategories();
      final categoryMap = {
        for (var c in categories) c['id'] as String: c['name'] as String,
      };

      final transactions = await _transactionService.getTransactions(
        categoryMap,
      );

      setState(() {
        _allTransactions = transactions;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load your transactions. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Re-applies search text + type filter on top of the full list.
  // Called whenever the user types in search or taps a filter chip.
  void _applyFilters() {
    setState(() {
      _transactions = _allTransactions.where((tx) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            query.isEmpty ||
            tx.categoryName.toLowerCase().contains(query) ||
            (tx.description ?? '').toLowerCase().contains(query) ||
            tx.amount.toString().contains(query);
        final matchesType = _filterType == null || tx.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: () async {
          // Wait for the add-transaction screen to close, then refresh the list
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          _loadTransactions();
        },
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by category, description, or amount',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _filterChip('All', null),
              const SizedBox(width: 8),
              _filterChip('Income', 'income'),
              const SizedBox(width: 8),
              _filterChip('Expense', 'expense'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
          if (type == null) {
            // "All" resets search too, not just the type filter
            _searchController.clear();
            _searchQuery = '';
          }
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.lightPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_transactions.isEmpty) {
      // Empty state - matches your spec's UX requirement
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text('No transactions yet', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'Add your first expense to start tracking your finances.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    //Dismissible = swipe-to-reveal-action (standard mobile pattern),
    // confirmDismiss shows a confirmation dialog before actually deleting
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        // Dismissible wraps the row so it can be swiped left to reveal a delete action.
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            // Ask before actually deleting - destructive action needs confirmation
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete transaction?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );
          },

          //onDismissed calls the real DELETE endpoint
          // then removes it from the local list so the UI updates instantly
          onDismissed: (direction) async {
            await _transactionService.deleteTransaction(tx.id);
            setState(() {
              _allTransactions.removeWhere((t) => t.id == tx.id);
              _transactions.removeAt(index);
            });
          },

          //tapping a row opens the same Add Transaction screen, but pre-filled
          // ( existingTransaction parameter) > after it closes, the list refreshes to show your edit
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddTransactionScreen(existingTransaction: tx),
                ),
              );
              _loadTransactions();
            },

            child: TransactionRow(
              categoryName: tx.categoryName,
              description: tx.description,
              amount: tx.amount,
              isIncome: tx.type == 'income',
              icon: CategoryIcons.getIcon(tx.categoryName),
              iconColor: CategoryIcons.getColor(tx.categoryName),
              date: tx.transactionDate,
            ),
          ),
        );
      },
    );
  }
}
