class EasyAuthOptions {
  /// Endpoints that should never trigger authentication logic.
  final List<String> excludedPaths;

  /// Header used for the access token.
  final String authorizationHeader;

  /// Prefix before the access token.
  final String authorizationScheme;

  const EasyAuthOptions({
    this.excludedPaths = const [],
    this.authorizationHeader = 'Authorization',
    this.authorizationScheme = 'Bearer',
  });

  bool isExcluded(String path) {
    return excludedPaths.any(path.startsWith);
  }
}