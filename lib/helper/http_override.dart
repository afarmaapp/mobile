import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  // https://github.com/flutter/flutter/issues/19588#issuecomment-406779390
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
