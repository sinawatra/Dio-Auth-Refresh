import '../model/auth_tokens.dart';

abstract class TokenStorage {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> save(AuthTokens tokens);

  Future<void> clear();
}
