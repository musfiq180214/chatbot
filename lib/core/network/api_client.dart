import 'dart:convert';
import 'package:chatbot/core/constants/urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logger/app_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer ${ApiUrls.apiKey}',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          AppLogger.logRequest(options.uri.toString(), options.data);
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          AppLogger.logResponse(response.requestOptions.uri.toString(), response.data);
        }
        return handler.next(response);
      },
      onError: (err, handler) {
        if (kDebugMode) {
          AppLogger.logError(err.requestOptions.uri.toString(), err.message);
        }
        return handler.next(err);
      },
    ),
  );

  return dio;
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// POST request with optional headers
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (headers != null) ...headers,
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  /// GET request with optional headers
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (headers != null) ...headers,
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }
}

final apiClientProvider = Provider((ref) => ApiClient(ref.watch(dioProvider)));