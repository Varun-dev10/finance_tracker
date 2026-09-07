import '../../../core/network/api_client.dart';
// padLeft(2, '0') turns 9 into "09" so the date always looks like 2026-09-01,
class BudgetService {
  final _apiClient = ApiClient();

  Future<Map<String, dynamic>> getBudget(DateTime month) async {
    final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
    final response = await _apiClient.dio.get('/budget', queryParameters: {'month': monthStr});
    return response.data;
  }

  Future<void> setBudget(DateTime month, double amount) async {
    final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
    await _apiClient.dio.put('/budget', data: {
      'month': monthStr,
      'amount': amount,
    });
  }
}