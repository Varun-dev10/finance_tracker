/* category dropdown filters by Income/Expense type and reloads when user switch type,
so you never accidentally pick "Salary" for an expense.
double.tryParse + validation stops empty/invalid amounts before hitting the API */

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/category_service.dart';
import '../data/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryService = CategoryService();
  final _transactionService = TransactionService();

  String _type = 'expense'; // 'expense' or 'income'
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      _categories = categories.where((c) => c['type'] == _type).toList();
      _isLoadingCategories = false;
      _selectedCategoryId = _categories.isNotEmpty ? _categories.first['id'] : null;
    });
  }

  // When user switches Income/Expense, reload the category list to match
  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      _isLoadingCategories = true;
    });
    _loadCategories();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.createTransaction(
        categoryId: _selectedCategoryId!,
        amount: amount,
        type: _type,
        description: _descriptionController.text.trim(),
        transactionDate: _selectedDate,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to save. Please try again.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Add Transaction'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income / Expense toggle
              Row(
                children: [
                  Expanded(
                    child: _typeButton('expense', 'Expense'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeButton('income', 'Income'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 16),

              _isLoadingCategories
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'] as String,
                    child: Text(c['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String type, String label) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.lightPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}