import 'package:dio/dio.dart';
import '../config/environment.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        error: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  String? _token;

  Dio get dio => _dio;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
}