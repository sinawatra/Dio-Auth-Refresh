import 'package:dio/dio.dart';
import '../model/auth_tokens.dart';
import 'token_parser.dart';

class JsonTokenParser extends TokenParser<AuthTokens> {
  @override
  Future<AuthTokens> parse(Response response) async {
    return AuthTokens(
      accessToken: response.data["accessToken"],
      refreshToken: response.data["refreshToken"],
    );
  }
}
