import '../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

//categoryMap is a lookup (category_id > category name) we build once from /categories,
// so we don't have to call the API separately for every single transaction just to know its
// category name. .toIso8601String().split('T')[0] converts a Dart date into the
// "2026-09-04" format, backend expects (just the date part, no time).

class TransactionService {
  final _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions(Map<String, String> categoryMap) async {
    final response = await _apiClient.dio.get('/transactions');
    final List data = response.data;

    return data.map((json) {
      final categoryName = categoryMap[json['category_id']] ?? 'Other';
      return TransactionModel.fromJson(json, categoryName);
    }).toList();
  }

  Future<void> createTransaction({
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _apiClient.dio.post('/transactions', data: {
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    });
  }

  // same shape as createTransaction, just calls PUT with the transaction's id in the URL instead of POST
  Future<void> updateTransaction({
    required String id,
    required String categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _apiClient.dio.put('/transactions/$id', data: {
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    });
  }
  Future<void> deleteTransaction(String id) async {
    await _apiClient.dio.delete('/transactions/$id');
  }
}