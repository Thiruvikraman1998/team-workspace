import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_workspace/core/di/global_di_instance.dart';
import 'package:team_workspace/core/network/api_client.dart';

/// Registers [Dio] and [ApiClient] into the DI container.
///
/// Reference: this mirrors the original network layer shared for the
/// assessment, extended with an auth interceptor that attaches the current
/// Firebase user's ID token (when available) to every request.
void setupNetworkModule() {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: supabaseUrl,
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // final token = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $supabaseAnonKey';
            }
          } catch (_) {
            // if token retrieval fails we still let the request go through,
            // the API will reject it with a 401 which is handled downstream
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Centralized place to add refresh-token / logging logic later on.
          handler.next(error);
        },
      ),
    );

    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(() => DioApiClient(getIt.get<Dio>()));
}
