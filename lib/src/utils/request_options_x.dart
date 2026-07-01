import 'package:dio/dio.dart';
import 'request_flags.dart';

extension RequestOptionsX on RequestOptions {
  bool get isRetried => extra[RequestFlags.retried] == true;

  set retried(bool value) {
    extra[RequestFlags.retried] = value;
  }
}