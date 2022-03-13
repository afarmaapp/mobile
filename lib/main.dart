import 'dart:io';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller.dart/cotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'my_app.dart';
import 'helper/http_override.dart';

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

  GetIt.I.registerSingleton<CotationController>(CotationController());
}

void main() {
  startEnv();
  runApp(MyApp());
}
