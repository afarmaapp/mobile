import 'dart:io';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/modules/home/controllers/product/product_controller.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/shared/controllers/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'my_app.dart';
import 'helper/http_override.dart';

void startEnv() {
  // HTTPS
  HttpOverrides.global = new MyHttpOverrides();
  // Verifica se os Widgets foram inicializados
  // FirebaseNotifications().setUpFirebase();
  WidgetsFlutterBinding.ensureInitialized();
  startGetIts();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void startGetIts() {
  GetIt.I.registerSingleton<UserController>(UserController());
  GetIt.I.registerSingleton<LoginController>(LoginController());
  GetIt.I.registerSingleton<CotationController>(CotationController());
  GetIt.I.registerSingleton<ProductController>(ProductController());
}

void main() {
  startEnv();
  runApp(Phoenix(child: MyApp()));
}
