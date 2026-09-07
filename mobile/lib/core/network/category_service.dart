import 'api_client.dart';

// Simple wrapper for fetching categories from the backend.
class CategoryService {
  final _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiClient.dio.get('/categories');
    return List<Map<String, dynamic>>.from(response.data);
  }
}