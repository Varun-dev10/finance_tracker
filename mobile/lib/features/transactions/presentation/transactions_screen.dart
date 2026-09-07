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

  List<TransactionModel> _transactions = [];
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
      // First fetch categories, build a quick lookup map (id -> name)
      final categories = await _categoryService.getCategories();
      final categoryMap = {
        for (var c in categories) c['id'] as String: c['name'] as String
      };

      final transactions = await _transactionService.getTransactions(categoryMap);

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          // Pull-to-refresh: user drags down to reload the list
          onRefresh: _loadTransactions,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        onPressed: () async {
          // Wait for the add-transaction screen to close, then refresh the list
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          _loadTransactions();
        },
        child: const Icon(Iconsax.add, color: Colors.white),
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

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        return TransactionRow(
          categoryName: tx.categoryName,
          description: tx.description,
          amount: tx.amount,
          isIncome: tx.type == 'income',
          icon: CategoryIcons.getIcon(tx.categoryName),
          iconColor: CategoryIcons.getColor(tx.categoryName),
        );
      },
    );
  }
}