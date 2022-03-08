import 'dart:io';
import 'package:afarma/helper/popularHelpers/CurrentDeviceInfo.dart';
import 'package:afarma/model/popularModels/Version.dart';
import 'package:afarma/repository/popularRepositories/VersionManager.dart';
import 'package:device_info/device_info.dart';
// import 'package:flutter_restart/flutter_restart.dart';
import 'package:package_info/package_info.dart';

import 'package:path_provider/path_provider.dart';

class DefaultUrlUri {
  static String afarmaUrl = 'https://server.afarmapopular.com.br';
  static String afarmaUri = '/afarma-mobile-rest/api';
}

class Return {
  Return({this.responseCode, this.returnBody});

  int? responseCode;
  List? returnBody;
}

class VersionApp {
  VersionApp({this.id, this.vAPP, this.active});

  int? id;
  String? vAPP;
  bool? active;
}

class VersionController {
  VersionController(
      {this.baseURL: 'https://server.afarmapopular.com.br',
      this.baseURI: '/afarma-mobile-rest/api',
      this.isDifferent: false});

  final String baseURL;
  final String baseURI;
  bool isDifferent;

  static Future<void> setAppVersion(
      bool firstTime, String vAPP, String idVersion) async {
    final dir = await getApplicationDocumentsDirectory();
    print('VERSÃO === $idVersion');
    try {
      final file = File('${dir.path}/appVersion.txt');
      if (firstTime == true) {
        firstTime = false;
        vAPP = '$vAPP';
        idVersion = '$idVersion';

        // firstTime = false;
        // vAPP = '1.0.0';
        // idVersion = '0';
      }
      file.writeAsString('$vAPP::$idVersion');

      // FlutterRestart.restartApp();
    } catch (error) {
      print('error saving version file');
    }
  }

  // Future<void> verifyVersion() async {
  //   String localVersion;
  //   bool versionExists = await VersionController.fileExists();

  //   // Chamar serviço para descobrir a Versão
  //   List<Version> versionApp = await VersionManager().refreshVersions();

  //   if (versionExists == false) {
  //     VersionController.setAppVersion(
  //         true, '${versionApp[0].vAPP}', '${versionApp[0].id}');
  //   } else {
  //     String remoteVersion = '${versionApp[0].vAPP}::${versionApp[0].id}';
  //     localVersion = await VersionController.getAppVersion();
  //     print('Versão Local: $localVersion \nVersão Remota: $remoteVersion');

  //     if (localVersion == remoteVersion) {
  //       this.isDifferent = false;
  //     } else {
  //       this.isDifferent = true;
  //     }

  //     print(isDifferent);
  //   }
  // }

  Future<void> verifyVersion() async {
    AndroidDeviceInfo? androidDeviceInfo =
        CurrentDeviceInfo().deviceInfo as AndroidDeviceInfo?;
    IosDeviceInfo? iosDeviceInfo =
        CurrentDeviceInfo().deviceInfo as IosDeviceInfo?;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    bool isSimulator;

    // Chamar serviço para descobrir a Versão
    List<Version> versionApp = await VersionManager().refreshVersions();

    String appVersion =
        versionApp[0].vAPP!.substring(7, versionApp[0].vAPP!.length - 14);
    String localVersion = packageInfo.version;
    print('Versão Local: $localVersion \nVersão Remota: $appVersion');

    if (Platform.isAndroid) {
      isSimulator = !androidDeviceInfo!.isPhysicalDevice;
    } else {
      isSimulator = !iosDeviceInfo!.isPhysicalDevice;
    }

    if (isSimulator) {
      this.isDifferent = false;
    } else if (localVersion == appVersion) {
      this.isDifferent = false;
    } else {
      this.isDifferent = true;
    }

    print(isDifferent);
  }

  static fileExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/appVersion.txt');

    var fileExist = file.exists();

    return fileExist;
  }

  static Future<String> getAppVersion() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/appVersion.txt');
      final version = await file.readAsString();

      print(version);

      return version;
    } catch (error) {
      print(error);
      return 'noVersion';
    }
  }
}
