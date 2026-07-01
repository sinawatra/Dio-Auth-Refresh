


import 'package:dio_auth_refresh/dio_auth_refresh.dart';

abstract class TokenStorage {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> save(AuthTokens tokens);

  Future<void> clear();
}