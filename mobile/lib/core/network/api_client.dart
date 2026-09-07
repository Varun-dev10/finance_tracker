import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// This is the ONE place that knows how to talk to our FastAPI backend.
// Every screen that needs to call the API uses this instead of
// writing raw HTTP requests everywhere.


class ApiClient {
  // Change this if PC's IP changes (e.g. different Wi-Fi network).
  static const String baseUrl = 'http://192.168.29.103:8000';

  static const _storage = FlutterSecureStorage();

  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));

    // This runs before every single request - automatically attaches
    // the saved JWT token, so we don't have to add it manually every time.



// Interceptor = code that runs automatically on every API call
// this one grabs the saved token and attaches it as the Authorization header,
// so individual screens never have to think about it

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}