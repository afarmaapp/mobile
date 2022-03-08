enum Environment { prod, dev, profile }

class DefaultURL {
  static Environment env = Environment.dev;

  static String apiURL() => _urls[env.index];

  static String apiURLFromEnv(Environment environment) =>
      _urls[environment.index];

  static const String _prod = 'https://server.afarma.app.br/afarma-skp-client';
  static const String _dev = 'https://server.afarma.app.br/afarma-skp-client';
  static const String _profile =
      'https://server.afarma.app.br/afarma-skp-client';
  static const int _defaultTimeout = 10000;

  static const List<String> _urls = [_prod, _dev, _profile];

  static List<String> urls() => _urls;

  static int defaultTimeout() => _defaultTimeout;
}

class DefaultURI {
  static String auth = '/afarma-skp-client';
  static String afarma = '/afarma-skp-client';
}

class GoogleAPI {
  static String key = '';
}
