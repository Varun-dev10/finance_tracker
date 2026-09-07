import '../../../core/network/api_client.dart';
 //two simple calls matching  backend endpoints
// > summary (balance/income/expenses) and category breakdown (for a chart later)
class DashboardService {
  final _apiClient = ApiClient();

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _apiClient.dio.get('/dashboard/summary');
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getCategoryBreakdown() async {
    final response = await _apiClient.dio.get('/dashboard/categories');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getMonthly() async {
    final response = await _apiClient.dio.get('/dashboard/monthly');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getRawTransactions() async {
    final response = await _apiClient.dio.get('/transactions');
    return List<Map<String, dynamic>>.from(response.data);
  }
}