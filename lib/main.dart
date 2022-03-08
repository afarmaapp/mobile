import 'dart:io';
import 'package:afarma/page/VersionPage.dart';
import 'package:afarma/service/Firebase/FirebaseNotificationHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyApp.dart';
import 'helper/HttpOverride.dart';

void startEnv() {
  // HTTPS
  HttpOverrides.global = new MyHttpOverrides();
  // Verifica se os Widgets foram inicializados
  // FirebaseNotifications().setUpFirebase();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Versão
  VersionPage().verifyVersion();
}

void main() {
  startEnv();
  runApp(MyApp());
}
