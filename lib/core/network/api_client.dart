import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

// Provides the base Dio client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.cloudflare.com/client/v4/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Inject authentication headers
  final account = ref.watch(authProvider).value;
  if (account != null) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Auth-Email'] = account.email;
        options.headers['X-Auth-Key'] = account.apiKey;
        return handler.next(options);
      },
    ));
  }

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});
