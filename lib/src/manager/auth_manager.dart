import 'package:dio/dio.dart';
import '../motex/refresh_mutex.dart';
import '../config/easy_auth_options.dart';
import '../model/auth_tokens.dart';
import '../refresh/refresh_handler.dart';
import '../storage/token_storage.dart';

class AuthenticationManager {
  final Dio dio;
  final TokenStorage tokenStorage;
  final RefreshHandler refreshHandler;
  final EasyAuthOptions options;
  final RefreshMutex mutex;

  AuthenticationManager({
    required this.dio,
    required this.tokenStorage,
    required this.refreshHandler,
    required this.options,
    required this.mutex,
  });

  Future<String?> accessToken() {
    return tokenStorage.getAccessToken();
  }

  Future<void> clear() async {
    await tokenStorage.clear();
  }

  Future<AuthTokens> refreshToken() async {
    // Someone else is already refreshing.
    if (mutex.isLocked) {
      await mutex.wait();

      final access = await tokenStorage.getAccessToken();
      final refresh = await tokenStorage.getRefreshToken();

      if (access == null || refresh == null) {
        throw Exception("Authentication failed");
      }

      return AuthTokens(
        accessToken: access,
        refreshToken: refresh,
      );
    }

    mutex.lock();

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception("No refresh token");
      }

      final tokens = await refreshHandler.refresh(refreshToken);

      await tokenStorage.save(tokens);

      mutex.unlock();

      return tokens;
    } catch (e) {
      await tokenStorage.clear();

      mutex.reject(e);

      rethrow;
    }
  }

  Future<Response<dynamic>> retry(
    RequestOptions request,
    String accessToken,
  ) {
    request.headers[options.authorizationHeader] =
        '${options.authorizationScheme} $accessToken';

    return dio.fetch(request);
  }
}
