import 'package:dio/dio.dart';

import '../manager/auth_manager.dart';
import '../utils/request_flags.dart';
import '../utils/request_options_x.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthenticationManager auth;

  AuthInterceptor({
    required this.dio,
    required this.auth,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (auth.options.isExcluded(options.path)) {
      return handler.next(options);
    }

    final token = await auth.tokenStorage.getAccessToken();

    if (token != null && !options.headers.containsKey(auth.options.authorizationHeader)) {
      options.headers[auth.options.authorizationHeader] =
          '${auth.options.authorizationScheme} $token';
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

    if (auth.options.isExcluded(request.path)) {
      return handler.next(err);
    }

    if (request.extra[RequestFlags.isRefreshing] == true) {
      return handler.next(err);
    }

    if (request.isRetried) {
      return handler.next(err);
    }

    try {
      final tokens = await auth.refreshToken();

      final response = await dio.fetch(
        request.copyWith(
          headers: {
            ...request.headers,
            auth.options.authorizationHeader:
                '${auth.options.authorizationScheme} ${tokens.accessToken}',
          },
          extra: {
            ...request.extra,
            RequestFlags.retried: true,
          },
        ),
      );

      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}
