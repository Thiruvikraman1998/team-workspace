import 'package:dio/dio.dart';

abstract class ApiClient {
  Future<Response<T>> get<T>(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    Options? options,
  });

  Future<Response<T>> post<T>(String endPoint, {dynamic data, Options? options});

  Future<Response<T>> put<T>(String endPoint, {dynamic data, Options? options});

  Future<Response<T>> patch<T>(String endPoint, {dynamic data, Options? options});

  Future<Response<T>> delete<T>(String endPoint, {dynamic data, Options? options});
}

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient(this._dio);

  @override
  Future<Response<T>> get<T>(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) {
    return _dio.get(endPoint, queryParameters: queryParams, options: options);
  }

  @override
  Future<Response<T>> post<T>(String endPoint, {data, Options? options}) {
    return _dio.post(endPoint, data: data, options: options);
  }

  @override
  Future<Response<T>> put<T>(String endPoint, {data, Options? options}) {
    return _dio.put(endPoint, data: data, options: options);
  }

  @override
  Future<Response<T>> patch<T>(String endPoint, {data, Options? options}) {
    return _dio.patch(endPoint, data: data, options: options);
  }

  @override
  Future<Response<T>> delete<T>(String endPoint, {data, Options? options}) {
    return _dio.delete(endPoint, data: data, options: options);
  }
}
