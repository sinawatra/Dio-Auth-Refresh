## Dio Refresh Token

Automatic token refresh + retry interceptor for Dio.

## Features

- Attach Authorization header automatically
- Refresh token on 401
- Retry request once
- Prevent duplicate refresh calls
- Request queue during refresh

## Usage

```dart
dio.interceptors.add(
  EasyAuthInterceptor(
    dio: dio,
    auth: authManager,
    refreshController: refreshController,
  ),
);"# Dio-Auth-Refresh" 
