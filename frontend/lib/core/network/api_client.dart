import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../services/token_service.dart';

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

    _aiDio = Dio(
      BaseOptions(
        baseUrl: Environment.aiBackendUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 120), // Longer for AI generation
        receiveTimeout: const Duration(seconds: 120), // Longer for AI generation
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _setupInterceptors(_dio);
    _setupInterceptors(_aiDio);
  }

  void _setupInterceptors(Dio dioInstance) {
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _token ?? await TokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await TokenService.clearToken();
            _token = null;
          }
          handler.next(error);
        },
      ),
    );

    dioInstance.interceptors.add(
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
  late final Dio _aiDio;
  String? _token;

  Dio get dio => _dio;
  Dio get aiDio => _aiDio;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() => _token = null;
}