📦 Dio Refresh Token

A lightweight Dio interceptor for automatic access token refresh, request retry, and safe concurrent request handling in Flutter apps.

✨ Features
🔐 Automatically attach Authorization header
🔄 Auto refresh access token on 401
♻️ Retry original request after refresh
🧠 Prevent multiple simultaneous refresh calls (mutex lock)
⏳ Queue requests while refreshing
🚫 Skip excluded endpoints
🧩 Fully customizable token storage
🔌 Custom refresh API handler
🛡 Prevent infinite retry loops
🚀 Installation

Add dependency:

dependencies:
  dio_refresh_token: ^0.3.0
⚙️ Basic Setup
import 'package:dio/dio.dart';
import 'package:dio_refresh_token/dio_refresh_token.dart';

final dio = Dio();

dio.interceptors.add(
  DioRefreshInterceptor(
    dio: dio,
    authManager: authManager,
    refreshController: refreshController,
  ),
);
🔐 Token Model
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}
💾 Token Storage

Implement your own storage (Secure Storage, Hive, etc.)

abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> save(AuthTokens tokens);
  Future<void> clear();
}
🔄 Refresh Handler

Define how your API refresh works:

abstract class RefreshHandler {
  Future<AuthTokens> refresh(String refreshToken);
}

Example:

class MyRefreshHandler implements RefreshHandler {
  final Dio dio;

  MyRefreshHandler(this.dio);

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await dio.post(
      "/refresh",
      data: {"refreshToken": refreshToken},
    );

    return AuthTokens(
      accessToken: response.data["accessToken"],
      refreshToken: response.data["refreshToken"],
    );
  }
}
🧠 How It Works
Request → Attach Token
         ↓
      401 Error
         ↓
   Refresh Token (ONLY ONCE)
         ↓
 Queue waiting requests
         ↓
 Retry original request
🚫 Skip Endpoints
final options = DioRefreshOptions(
  excludedPaths: [
    "/login",
    "/refresh",
  ],
);
⚡ Example Usage
final dio = Dio();

final authManager = AuthManager(
  tokenStorage: MyStorage(),
  refreshHandler: MyRefreshHandler(dio),
);

final refreshController = RefreshController(
  authManager: authManager,
  queue: RequestQueue(),
  mutex: RefreshMutex(),
);

dio.interceptors.add(
  DioRefreshInterceptor(
    dio: dio,
    authManager: authManager,
    refreshController: refreshController,
  ),
);
🧠 Architecture
Interceptor
   ↓
AuthManager
   ↓
RefreshController
   ↓
TokenStorage + RefreshHandler
   ↓
RequestQueue + Mutex
⚠️ Notes
Only retries each request once
Prevents infinite refresh loops
Safe for concurrent API calls
Designed for production apps
📈 Roadmap
 Retry policy (exponential backoff)
 JWT auto-expiry detection
 Logging system
 Dio + HTTP adapter support
 Offline queue sync
📄 License

MIT

👨‍💻 Author

Built for production Flutter apps using Dio with clean architecture and scalable authentication flow.