import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';

class DioClient {
  DioClient({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        _dio = _buildDio(baseUrl);

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  bool _isRefreshing = false;

  static Dio _buildDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client': 'nucleus-flutter/1.0',
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(secureStorage: _secureStorage, client: this),
      _LoggingInterceptor(),
      _RetryInterceptor(dio: _dio),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
      _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: StorageKeys.accessToken),
      _secureStorage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  Future<String?> refreshAccessToken() async {
    if (_isRefreshing) return null;
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return null;

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'skipAuth': true}),
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } catch (_) {
      await clearTokens();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.secureStorage,
    required this.client,
  });

  final FlutterSecureStorage secureStorage;
  final DioClient client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['skipAuth'] == true) {
      options.headers.remove('skipAuth');
      return handler.next(options);
    }

    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final newToken = await client.refreshAccessToken();
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await client.dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In dev: print request details
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required this.dio});

  final Dio dio;
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
    final isNetworkError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isNetworkError && retryCount < maxRetries) {
      final delay = initialDelay * (1 << retryCount); // Exponential backoff
      await Future.delayed(delay);

      err.requestOptions.extra['retryCount'] = retryCount + 1;
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Fall through to next handler
      }
    }

    handler.next(err);
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  final int statusCode;
  final String message;
  final String? code;

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    final message = (data is Map ? data['message'] : null) as String? ??
        e.message ??
        'An error occurred';
    final code = (data is Map ? data['code'] : null) as String?;

    return ApiException(
      statusCode: statusCode,
      message: message,
      code: code,
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Provider
final dioClientProvider = Provider<DioClient>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
