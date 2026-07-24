import 'package:dio/dio.dart';

class DioErrorMappers {
  const DioErrorMappers._();

  static String map(DioExceptionType e) {
    switch (e) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return "Please check your network connection";

      case DioExceptionType.cancel:
        return "Request was cancelled";

      case DioExceptionType.badResponse:
        return "Bad response error";

      case DioExceptionType.badCertificate:
        return "Bad Certificate Error";

      case DioExceptionType.connectionError:
        return "Error establishing connection";

      case DioExceptionType.unknown:
      default:
        return "Something went wrong";
    }
  }

  static String fromException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return map(e.type);
  }
}
