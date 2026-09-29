enum AppEnvironment { dev, staging, prod }

class Environment {
  const Environment._(this.name, this.apiBaseUrl);

  final AppEnvironment name;
  final String apiBaseUrl;

  static const Environment dev = Environment._(
    AppEnvironment.dev,
    'http://localhost:8080',
  );

  static const Environment staging = Environment._(
    AppEnvironment.staging,
    'https://staging-api.pathseek.pe',
  );

  static const Environment prod = Environment._(
    AppEnvironment.prod,
    'https://api.pathseek.pe',
  );

  static const Environment current = Environment.dev;

  bool get isProduction => name == AppEnvironment.prod;
}
