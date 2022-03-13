// ignore_for_file: file_names

enum Environment { prod, dev, profile }

class DefaultURL {
  static Environment env = Environment.dev;

  static String apiURL() => _urls[env.index];

  static String buckerURL() => 'https://images.afarma.app.br';

  static String apiURLFromEnv(Environment environment) =>
      _urls[environment.index];

  static const String _prod = 'https://api.afarma.app.br';
  static const String _dev = 'https://api.afarma.app.br';
  static const String _profile = 'https://api.afarma.app.br';
  static const int _defaultTimeout = 10000;

  static const List<String> _urls = [_prod, _dev, _profile];

  static List<String> urls() => _urls;

  static int defaultTimeout() => _defaultTimeout;
}

class DefaultURI {
  static String afarma = '/afarma-skp-client';
}

class GoogleAPI {
  static String key = 'AIzaSyBLjJKTJ4fQhL3v6isCmX0BOYkKvUA41l8';
}
