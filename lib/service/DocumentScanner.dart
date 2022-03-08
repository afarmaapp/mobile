import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_genius_scan/flutter_genius_scan.dart';
// import 'package:open_file/open_file.dart';

late String geniusScanKeyAndroid;
late String geniusScanKeyIOS;

class DocumentScanner {
  static MethodChannel _channel = MethodChannel('flutter_genius_scan');

  static Future<File> getDocument(String typeScan, context) async {
    File ret;
    Map configuration = {
      'source': 'camera',
      'multiPage': false,
      'defaultFilter': typeScan == 'blackAndWhite' ? 'blackAndWhite' : 'photo',
      'postProcessingActions': [],
      'foregroundColor': '#efefef',
      'backgroundColor': '#F44336',
      'highlightColor': '#000000',
      'menuColor': '#F44336',
    };

    FlutterGeniusScan.setLicenceKey(Platform.isAndroid
        ? await _getGeniusKeyAndroid()
        : await _getGeniusKeyIOS());

    Map result =
        await _channel.invokeMethod('scanWithConfiguration', configuration);

    String scan = result['scans'][0]['enhancedUrl'];

    ret = File(scan.replaceAll('file://', ''));

    return ret;
  }

  // static Future<File> getDocument(ImageSource src, context) async {
  //   File ret;
  //   var status = await Permission.camera.status;
  //   if (status.isGranted) {
  //     //ImagePicker().getImage(source: ImageSource.gallery);
  //     var callReturn = await _channel.invokeMethod('callScanner');
  //     if (callReturn != null) {
  //       ret = File(callReturn);
  //     }

  //     return ret;
  //   } else {
  //     await showDialog(
  //         builder: (context) {
  //           return AlertDialog(
  //             actions: [
  //               FlatButton(
  //                 child: Text('Sim'),
  //                 onPressed: () {
  //                   openAppSettings();
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //               FlatButton(
  //                 child: Text('Não'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             ].reversed.toList(),
  //             content: Text(
  //               'Deseja permitir a utilização da câmera?',
  //               textAlign: TextAlign.center,
  //             ),
  //           );
  //         },
  //         context: context);

  //     return null;
  //   }
  // }

  // static Future<void> requestPermission() async {
  //   if (Platform.isAndroid) await Permission.camera.request().isGranted;
  // }

  static Future<String> _getGeniusKeyAndroid() async {
    // if (geniusScanKeyAndroid != null) return geniusScanKeyAndroid;
    Connector connector =
        Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
    final resp = await connector.getContent('/api/autenticacao/gToken');
    if (resp.responseCode! < 400) {
      Map parsed = jsonDecode(resp.returnBody!);
      if (parsed.containsKey('geniusScanLicence') &&
          parsed['geniusScanLicence'] != null) {
        geniusScanKeyAndroid = parsed['geniusScanLicence'];
        return geniusScanKeyAndroid;
      }
    }
    return geniusScanKeyAndroid = 'noGeniusScanLicence';
  }

  static Future<String> _getGeniusKeyIOS() async {
    // if (geniusScanKeyIOS != null) return geniusScanKeyIOS;
    Connector connector =
        Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
    final resp = await connector.getContent('/api/autenticacao/gToken');
    if (resp.responseCode! < 400) {
      Map parsed = jsonDecode(resp.returnBody!);
      if (parsed.containsKey('geniusScanLicenceAfarma') &&
          parsed['geniusScanLicenceAfarma'] != null) {
        geniusScanKeyIOS = parsed['geniusScanLicenceAfarma'];
        return geniusScanKeyIOS;
      }
    }
    return geniusScanKeyIOS = 'noGeniusScanLicenceAfarma';
  }

  static Future<void> cleanup() async {
    if (Platform.isIOS) await _channel.invokeMethod('cleanup');
  }
}

/*
File ret;
    if (Platform.isIOS) {
      PickedFile pickedImage = await ImagePicker().getImage( source: src );
      var callReturn = await MethodChannel('opencv').invokeMethod('convertToGray', {
        'filePath': pickedImage.path,
        'tl_x': -1,
        'tl_y': -1,
        'tr_x': -1,
        'tr_y': -1,
        'bl_x': -1,
        'bl_y': -1,
        'br_x': -1,
        'br_y': -1
      });
      if (callReturn != null) {
        ret = File(callReturn);
      }
    } else {
      var callReturn = await _channel.invokeMethod('callScanner');
      if (callReturn != null) {
        ret = File(callReturn);
      }
    }
    return ret;

  File ret;
    var callReturn = await _channel.invokeMethod('callScanner');
    if (callReturn != null) {
      ret = File(callReturn);
    }
    return ret;

*/
