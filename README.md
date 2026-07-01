# dio_auth_refresh

A lightweight Dio interceptor for automatically attaching access tokens, refreshing tokens on 401, and retrying the original request safely (single refresh call at a time).

## Features

- Automatically attach an Authorization header (configurable header + scheme)
- Refresh access token on 401 (with excluded paths)
- Retry the original request once after a successful refresh
- Prevent multiple simultaneous refresh calls (mutex lock)

## Installation

Add dependency:

```yaml
dependencies:
  dio_auth_refresh: ^0.0.1
```

## Usage

1) Implement `TokenStorage` (Secure Storage, Hive, etc.)
2) Implement `RefreshHandler` (how your API refresh works)
3) Create an `AuthenticationManager`
4) Add `AuthInterceptor` to your Dio instance

```dart
import 'package:dio/dio.dart';
import 'package:dio_auth_refresh/dio_auth_refresh.dart';

class MemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<String?> getAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> getRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> save(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<void> clear() async {
    _tokens = null;
  }
}

class MyRefreshHandler implements RefreshHandler {
  final Dio dio;

  MyRefreshHandler(this.dio);

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await dio.post(
      'https://---ur--refresh-token--api/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = response.data['data'] as Map<String, dynamic>;

    return AuthTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}

final apiDio = Dio();
final refreshDio = Dio();

final auth = AuthenticationManager(
  dio: apiDio,
  tokenStorage: MemoryTokenStorage(),
  refreshHandler: MyRefreshHandler(refreshDio),
  options: const EasyAuthOptions(
    excludedPaths: ['/api/v1/auth/login', '/api/v1/auth/refresh'],
  ),
  mutex: RefreshMutex(),
);

apiDio.interceptors.add(
  AuthInterceptor(
    dio: apiDio,
    auth: auth,
  ),
);
```

Notes:

- Use a separate `Dio` instance for refresh calls (`refreshDio`) or ensure your refresh endpoint is in `excludedPaths` to prevent interceptor recursion.
- `AuthInterceptor` will only retry a request once to avoid infinite refresh loops.
- If your backend returns `{ statusCode, message, data }`, parse tokens from `response.data['data']`.
