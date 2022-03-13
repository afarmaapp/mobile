import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_restart/flutter_restart.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'helper/app_colors.dart';
import 'helper/config.dart';
import 'helper/connector.dart';
import 'helper/current_device_info.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    requestPermission();
  }

  void requestPermission() async {
    // if (await Permission.locationWhenInUse.serviceStatus.isDisabled) {
    //   if (Platform.isAndroid) {
    //     if (await Permission.location.request().isGranted) {
    //       // log('Localização autorizada');
    //       Phoenix.rebirth(context);
    //     } else {
    //       // log('Localização não autorizada');
    //     }
    //   }
    // }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aFarma',
      theme: ThemeData(primarySwatch: AppColors.primary, fontFamily: 'Roboto'),
      home: FutureBuilder<Widget>(
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(home: Splash());
          } else {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return Container();
            }
          }
        },
        future: _mainWidget(),
      ),
    );
  }

  Future<Widget> _mainWidget() async {
    // Dados do dispositivo
    CurrentDeviceInfo().getCurrentDeviceInfo();

    // Pega os dados do usuário
    if (await Connector(
      baseURL: DefaultURL.apiURL(),
      baseURI: DefaultURI.afarma,
    ).hasKey()) {
      User.fetch();
    }

    return MainTabController();
  }
}
