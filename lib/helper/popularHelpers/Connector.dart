import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:afarma/repository/popularRepositories/AdBannerManager.dart';
import 'package:afarma/repository/popularRepositories/AddressManager.dart';
import 'package:afarma/repository/popularRepositories/Cart.dart';
import 'package:afarma/repository/popularRepositories/MedicationManager.dart';
import 'package:afarma/repository/popularRepositories/PurchaseManager.dart';
import 'package:afarma/repository/popularRepositories/SegmentManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:afarma/page/afarmaPopular/profile/LoginController.dart';
import 'package:afarma/service/popularServices/User.dart';

/*
    JWT eyJraWQiOiJkZW1vaXNlbGxlLXNlY3VyaXR5LWp3dCIsImFsZyI6IlJTMjU2In0.eyJpc3MiOiJBRkFSTUEtTU9CSUxFIiwiZXhwIjoxNjM0ODU0NjI2LCJhdWQiOiJwcm9ncmVzc2l2ZSIsImp0aSI6IlIxZnpGYV9ZX2l0YlNTVnlyRXBHeHciLCJpYXQiOjE2MDMzMTg2MjYsIm5iZiI6MTYwMzMxODU2NiwiaWRlbnRpdHkiOiIxNCIsIm5hbWUiOiJSb25hbGRvIFNhbnRhbmEiLCJyb2xlcyI6WyJBRE1JTklTVFJBRE9SIl0sInBlcm1pc3Npb25zIjp7fSwicGFyYW1zIjp7IkVtYWlsIjoicm9uYWxkc3N4QGljbG91ZC5jb20iLCJUZWxlZm9uZSI6InN0cmluZyIsImxvamFJZCI6IjEyMzQ1Njc4OTAifX0.Lrl_-X9SlYG-Ar3iw21WJwso4yGiUOj1a1baQSGkYjRdPpiG2XjRjDwEDnQ_MK5IJsLTTOYKhYOcb14enfnAmx2KAG3olXLnFA2QJk7u_oUSzh3q03AP1FelArD5GCPIygJS1T7sYU_pMtve6RE2O-rnk4lLs9XHMVzz2q9U9nrTkiGhso3mPwc7wZVY7WRYasDylPT_SFirbJIKK5uZJAQ0KWEksjmDv0-AwrASmaxpMkGDejyAB7Z004qYKX_6uuUQLpOtshLpYXYzDeom0pol8mR8Fr6eqHPYOLheZ_ZVIF5zyp_QtaL2Bc9aopVMjbdi9ykOrL3OjHDAI0xiPg
*/

enum Environment { prod, dev, profile }

class DefaultURL {
  static Environment env = Environment.prod;

  static String apiURL() => _urls[env.index];

  static String apiURLFromEnv(Environment environment) =>
      _urls[environment.index];

  static const String _prod = 'https://server.afarmapopular.com.br';
  static const String _dev = 'https://server.afarmapopular.com.br';
  // static const String _dev = 'https://server.bda.dev.br';
  static const String _profile = 'https://server.afarmapopular.com.br';
  // static const String _profile = 'https://server-afarma.bda.tec.br';

  static const List<String> _urls = [_prod, _dev, _profile];
}

class DefaultURI {
  static String auth = '/gestao-rest';
  static String afarma = '/afarma-mobile-rest';
}

class Return {
  Return({this.responseCode, this.returnBody});

  int? responseCode;
  String? returnBody;
}

class Connector {
  static String? userKey;

  Connector({this.baseURL, this.baseURI});

  final String? baseURL;
  final String? baseURI;

  void _displayAlert(String title, String msg, BuildContext context) {
    final dialog = AlertDialog(
      actions: <Widget>[
        FlatButton(
            child: Text('ok'),
            onPressed: () {
              Navigator.pop(context);
            })
      ],
      content: Text(msg),
      title: Text(title),
    );
    showDialog(
        builder: (context) {
          return dialog;
        },
        context: context);
  }

  Future<void> _updateContent() async {
    SegmentManager().refreshSegments();
    MedicationManager().refreshMedications();
    AdBannerManager().getAds();
    PurchaseManager().refreshPurchases();
  }

  void handleStatus(int stat, BuildContext context) {
    switch (stat) {
      case 400:
        _displayAlert(stat.toString(), 'Requisição incorreta', context);
        break;
      case 401:
        _displayAlert(stat.toString(), 'Não autorizado', context);
        break;
      case 403:
        _displayAlert(stat.toString(), 'Não autenticado', context);
        break;
      case 404:
        _displayAlert(stat.toString(), 'Não localizado', context);
        break;
      case 500:
        _displayAlert(stat.toString(), 'Erro no servidor', context);
        break;
    }
  }

  static Future<void> setDeviceToken(String token) async {
    final dir = await getApplicationDocumentsDirectory();
    print('TOKEN ORIGINAL === $token');
    try {
      final file = File('${dir.path}/deviceTokenAfarmaPopular.txt');
      file.writeAsString(token);
    } catch (error) {
      print('error saving deviceToken file');
    }
  }

  static Future<String> getDeviceToken() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/deviceTokenAfarmaPopular.txt');
      final token = await file.readAsString();
      return token;
    } catch (error) {
      print(error);
      return 'noToken';
    }
  }

  Future<String?> getUserKey() async {
    if (userKey == null) {
      final dir = await getApplicationDocumentsDirectory();
      try {
        final file = File('${dir.path}/usrTokenAfarmaPopular.txt');
        final key = await file.readAsString();
        userKey = key;
        User.buildFromToken(key);
        return key;
      } catch (error) {
        print(error);
        return 'noKey';
      }
    } else {
      return userKey;
    }
  }

  static Future<void> resetUserKey() async {
    if (userKey == null) {
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/usrTokenAfarmaPopular.txt');
      file.delete();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _setUserKey(String rawKey) async {
    final dir = await getApplicationDocumentsDirectory();
    String key = jsonDecode(rawKey)['key'];
    User.buildFromToken(key);
    try {
      final file = File('${dir.path}/usrTokenAfarmaPopular.txt');
      file.writeAsString(key);
    } catch (error) {
      print('error saving key file');
    }
  }

  static Future<Environment> _getUserEnvironment() async {
    Environment? env;
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/env.txt');
      int intEnv = int.tryParse(file.readAsStringSync()) ?? 0;
      DefaultURL.env = Environment.values[intEnv];
    } catch (error) {
      print('no environment set!');
    }
    return env ?? Environment.prod;
  }

  static Future<void> _resetUserEnvironment() async {
    final dir = await getApplicationDocumentsDirectory();
    DefaultURL.env = Environment.prod;
    try {
      final file = File('${dir.path}/env.txt');
      file.delete();
    } catch (error) {
      print(error);
    }
  }

  static Future<void> _setUserEnvironment(Environment environment) async {
    final dir = await getApplicationDocumentsDirectory();
    DefaultURL.env = environment;
    try {
      final file = File('${dir.path}/env.txt');
      file.writeAsStringSync(environment.index.toString());
    } catch (error) {
      print(error);
    }
  }

  String parseParams(Map<String, String> params) {
    if (params.length == 0) {
      return '';
    }
    String param = '?';
    params.forEach((k, v) => param += '$k=$v&');
    if (param.endsWith('&')) {
      param = param.substring(0, param.length - 1);
    }
    return param;
  }

  Future<Return> getContentAndHandleError(
      String service, BuildContext context) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client
        .get(Uri.parse(this.baseURL! + this.baseURI! + service), headers: {
      'Accept': 'application/json',
      'Authorization': 'jwt $key',
      'Content-Type': 'application/json'
    }).timeout(Duration(seconds: 20));
    handleStatus(response.statusCode, context);
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> getContent(String service) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client
        .get(Uri.parse(this.baseURL! + this.baseURI! + service), headers: {
      'Accept': 'application/json',
      'Authorization': 'jwt $key',
      'Content-Type': 'application/json'
    }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> getContentWithParams(
      String service, Map<String, String> params) async {
    String? key = await getUserKey();
    http.Client client = http.Client();

    final response = await client.get(
        Uri.parse(
            this.baseURL! + this.baseURI! + service + parseParams(params)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'jwt $key',
          'Content-Type': 'application/json'
        }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> putContentWithBody(String service, String body) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client.put(
        Uri.parse(this.baseURL! + this.baseURI! + service),
        body: body,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'jwt $key',
          'Content-Type': 'application/json'
        }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> postContentWithBody(String service, String body) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client.post(
        Uri.parse(this.baseURL! + this.baseURI! + service),
        body: body,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'jwt $key',
          'Content-Type': 'application/json'
        }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> postContentWithParams(
      String service, Map<String, String> params, String body) async {
    String? key = await getUserKey();
    print(body);
    http.Client client = http.Client();
    final response = await client.post(
        Uri.parse(
            this.baseURL! + this.baseURI! + service + parseParams(params)),
        body: body,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'jwt $key',
          'Content-Type': 'application/json'
        }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> deleteContent(String service) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client
        .delete(Uri.parse(this.baseURL! + this.baseURI! + service), headers: {
      'Accept': 'application/json',
      'Authorization': 'jwt $key',
      'Content-Type': 'application/json'
    }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> deleteContentWithParams(
      String service, Map<String, String> params) async {
    String? key = await getUserKey();
    http.Client client = http.Client();
    final response = await client.delete(
        Uri.parse(
            this.baseURL! + this.baseURI! + service + parseParams(params)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'jwt $key',
          'Content-Type': 'application/json'
        }).timeout(Duration(seconds: 20));
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> loginWithParams(LoginInput input) async {
    Environment env;
    switch (input.loginModifier()) {
      case '+prod':
        env = Environment.prod;
        break;
      case '+dev':
        env = Environment.dev;
        break;
      case '+hom':
        env = Environment.profile;
        break;
      default:
        env = Environment.prod;
        break;
    }
    String url = '';
    if (DefaultURL._urls.contains(baseURL)) {
      if (baseURL == DefaultURL._urls[env.index]) {
        url += this.baseURL!;
      } else {
        url += DefaultURL._urls[env.index];
      }
    } else {
      url += this.baseURL!;
    }
    url += this.baseURI! + '/api/autenticacao';
    final body =
        '{\"email\": \"${input.filteredLogin()!.trim().toLowerCase()}\", \"senha\": \"${input.password!.trim()}\", \"deviceToken\": \"${await getDeviceToken()}\"}';
    final response = await http.post(Uri.parse(url), body: body, headers: {
      HttpHeaders.contentTypeHeader: 'application/json'
    }).timeout(Duration(seconds: 20));
    if (response.statusCode < 400) {
      final a = await Connector._setUserEnvironment(env);
      final b = await _setUserKey(response.body);
      final c = await User.fetch();
      final d = await _updateContent();
    }
    return Return(
        responseCode: response.statusCode,
        returnBody: utf8.decode(response.bodyBytes));
  }

  Future<Return> uploadPicture(
      String service, File picture, Map<String, String> fields) async {
    bool timedOut = false;
    String? key = await getUserKey();
    final url = Uri.parse(this.baseURL! + this.baseURI! + service);
    final request = http.MultipartRequest('POST', url);
    request.fields.addAll(fields);
    request.files.add(
        http.MultipartFile.fromBytes('image', await picture.readAsBytes()));
    final response = await request.send().timeout(Duration(seconds: 10));
    final body = await response.stream.toBytes();
    return Return(
        responseCode: timedOut ? -1 : response.statusCode,
        returnBody: utf8.decode(body));
  }

  Future<bool> hasKey() async {
    await Connector._getUserEnvironment();
    String? key = await getUserKey();
    return (key != 'noKey');
  }

  Future<bool> biometricLogin() async {
    String? userKey = await getUserKey();
    if (userKey == 'noKey') {
      return false;
    }
    User.buildFromToken(userKey);
    return true;
  }

  static Future<void> logout() async {
    await Connector.resetUserKey();
    await Connector._resetUserEnvironment();
    User.instance = null;
    AddressManager().clear();
    PurchaseManager().clear();
    Cart().clear();
  }
}
