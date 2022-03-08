import 'dart:io';

import 'package:afarma/model/Version.dart';
import 'package:afarma/repository/VersionRepository.dart';
import 'package:path_provider/path_provider.dart';

class VersionPage {
  VersionPage({this.isDifferent: false});

  bool isDifferent;

  static Future<void> setAppVersion(
      bool firstTime, String vAPP, String idVersion) async {
    final dir = await getApplicationDocumentsDirectory();
    // print('VERSÃO === $idVersion');
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
    } catch (error) {
      print('error saving version file');
    }
  }

  Future<void> verifyVersion() async {
    String localVersion;
    bool versionExists = await VersionPage.fileExists();

    // Chamar serviço para descobrir a Versão
    List<Version> versionApp = await VersionRepository().refreshVersions();

    if (versionApp.length == 0) {
      VersionPage.setAppVersion(true, 'Local', 'Local');
    } else {
      if (versionExists == false) {
        VersionPage.setAppVersion(
            true, '${versionApp[0].vAPP}', '${versionApp[0].id}');
      } else {
        String remoteVersion = '${versionApp[0].vAPP}::${versionApp[0].id}';

        localVersion = await VersionPage.getAppVersion();
        // print('Versão Local: $localVersion \nVersão Remota: $remoteVersion');

        this.isDifferent = !(localVersion == remoteVersion);
        // print(isDifferent);
      }
    }
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

      print("Versão Local $version");

      return version;
    } catch (error) {
      print(error);
      return 'noVersion';
    }
  }
}
