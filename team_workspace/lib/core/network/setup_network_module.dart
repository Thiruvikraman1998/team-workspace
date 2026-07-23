import 'package:dio/dio.dart';
import 'package:team_workspace/core/global_di_instance.dart';
import 'package:team_workspace/core/network/api_client.dart';

void setupNetworkModule({required String baseUrl}) {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "apikey": "sb_publishable_OuhwBSUfDptPK21W0Idk7Q_d2n5ffCG",
          "Authorization":
              " Bearer sb_publishable_OuhwBSUfDptPK21W0Idk7Q_d2n5ffCG",
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // we can add refresh, ssl pinning or other interceptor logic
          handler.next(options);
        },

        onError: ((error, handler) {
          // handle interceptors error
          handler.next(error);
        }),
      ),
    );

    return dio;
  });
  getIt.registerLazySingleton<ApiClient>(() => DioApiClient(getIt.get<Dio>()));
}
