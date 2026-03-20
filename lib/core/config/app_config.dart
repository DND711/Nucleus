enum Flavor { dev, staging, production }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
  });

  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;

  static const AppConfig dev = AppConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://api-dev.nucleus.app/api/v1',
    appName: 'Nucleus Dev',
  );

  static const AppConfig staging = AppConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://api-staging.nucleus.app/api/v1',
    appName: 'Nucleus Staging',
  );

  static const AppConfig production = AppConfig(
    flavor: Flavor.production,
    apiBaseUrl: 'https://api.nucleus.app/api/v1',
    appName: 'Nucleus',
  );

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProduction => flavor == Flavor.production;
}
