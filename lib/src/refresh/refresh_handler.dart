
import '../../dio_auth_refresh.dart';

abstract class RefreshHandler {
  Future<AuthTokens> refresh(String refreshToken);
}