import 'package:dio/dio.dart';

abstract class ApiClient {
  Future<Response<T>> get<T>(
    String endPoint, {
    Map<String, dynamic>? queryParams,
  });

  Future<Response<T>> post<T>(String endPoint, {dynamic data});

  Future<Response<T>> put<T>(String endPoint, {dynamic data});
}

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient(this._dio);
  @override
  Future<Response<T>> get<T>(
    String endPoint, {
    Map<String, dynamic>? queryParams,
  }) {
    return _dio.get(endPoint, queryParameters: queryParams);
  }

  @override
  Future<Response<T>> post<T>(String endPoint, {data}) {
    return _dio.post(endPoint, data: data);
  }

  @override
  Future<Response<T>> put<T>(String endPoint, {data}) {
    return _dio.put(endPoint, data: data);
  }
}
