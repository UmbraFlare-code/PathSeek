enum AppEnvironment { dev, staging, prod }

class Environment {
  const Environment._(this.name, this.apiBaseUrl);

  final AppEnvironment name;
  final String apiBaseUrl;

  static const Environment dev = Environment._(
    AppEnvironment.dev,
    String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080'),
  );

  static const Environment staging = Environment._(
    AppEnvironment.staging,
    String.fromEnvironment('API_BASE_URL', defaultValue: 'https://169.58.74.99'),
  );

  static const Environment prod = Environment._(
    AppEnvironment.prod,
    String.fromEnvironment('API_BASE_URL', defaultValue: 'https://169.58.74.99'),
  );

  static Environment get current {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    return switch (env) {
      'prod' => prod,
      'staging' => staging,
      _ => dev,
    };
  }

  bool get isProduction => name == AppEnvironment.prod;
}
