import '../../../core/network/api_client.dart';

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
}