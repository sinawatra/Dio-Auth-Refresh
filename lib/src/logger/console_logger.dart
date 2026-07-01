

import '../../dio_auth_refresh.dart';

class ConsoleLogger implements AuthLogger {
  @override
  void info(String message) {
    print(message);
  }

  @override
  void warning(String message) {
    print(message);
  }

  @override
  void error(String message) {
    print(message);
  }
}