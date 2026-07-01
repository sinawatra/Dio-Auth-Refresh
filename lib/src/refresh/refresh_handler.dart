import '../model/auth_tokens.dart';

abstract class RefreshHandler {
  Future<AuthTokens> refresh(String refreshToken);
}
