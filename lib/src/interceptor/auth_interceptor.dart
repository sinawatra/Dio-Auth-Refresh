import 'package:dio/dio.dart';
import '../manager/auth_manager.dart';
import '../refresh/refresh_handler.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final RefreshHandler refreshHandler;
  final Dio dio;
  final AuthenticationManager auth;

  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshHandler,
    required this.dio,
    required this.auth,
  });

  @override

  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (auth.options.isExcluded(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (request.extra['easy_auth_retried'] == true) {
        return handler.next(err);
      }

    try {
      // 1. Refresh token (handled by AuthenticationManager)
      final tokens = await auth.refreshToken();

      // 2. REBUILD request safely here (Interceptor responsibility)
      final request = err.requestOptions;

      final response = await dio.fetch(
        request.copyWith(
          headers: {
            ...request.headers,
            'Authorization': 'Bearer ${tokens.accessToken}',
          },
        ),
      );

      // 3. Return successful response
      return handler.resolve(response);

    } catch (e) {
      // refresh failed → forward error
      return handler.next(err);
    }
  }
}