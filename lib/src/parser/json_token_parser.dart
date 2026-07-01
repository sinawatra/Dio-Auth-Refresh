import 'package:dio/dio.dart';
import '../../dio_auth_refresh.dart';

class JsonTokenParser extends TokenParser<AuthTokens> {
  @override
  Future<AuthTokens> parse(Response response) async {
    return AuthTokens(
      accessToken: response.data["accessToken"],
      refreshToken: response.data["refreshToken"],
    );
  }
}