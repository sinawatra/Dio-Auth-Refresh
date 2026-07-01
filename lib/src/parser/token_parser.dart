import 'package:dio/dio.dart';

abstract class TokenParser<T> {
  Future<T> parse(Response response);
}