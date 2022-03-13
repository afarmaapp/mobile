// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:app/shared/Login.dart';
import 'package:app/shared/logged_in_notifier_service.dart';
import 'package:app/shared/models/User.dart';
import 'package:app/shared/return.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'config.dart';

class Connector {
  static String? userKey;

  Connector({required this.baseURL, required this.baseURI});

  Dio dio = Dio();

  final String baseURL;
  final String baseURI;

  void _displayAlert(String title, String msg, BuildContext context) {
    final dialog = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actions: <Widget>[
          FlatButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
        content: Text(msg),
        title: Text(title),
      ),
    );
    showDialog(
        builder: (context) {
          return dialog;
        },
        context: context);
  }

  // Future<void> _updateContent() async {
  //   DepartmentRepository().refreshDepartments();
  //   BannerRepository().refreshBanners();
  // }

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
    // print('TOKEN ORIGINAL === $token');
    try {
      final file = File('${dir.path}/deviceToken.txt');
      file.writeAsString(token);
    } catch (error) {
      print('error saving deviceToken file');
    }
  }

  static Future<String> getDeviceToken() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/deviceToken.txt');

      if (await file.exists()) {
        final token = await file.readAsString();
        return token;
      } else {
        return 'noToken';
      }
    } catch (error) {
      print(error);
      return 'noToken';
    }
  }

  Future<String> getUserKey() async {
    if (userKey == null) {
      final dir = await getApplicationDocumentsDirectory();
      try {
        final file = File('${dir.path}/usrToken.txt');
        if (await file.exists()) {
          final key = await file.readAsString();
          userKey = key;
          User.buildFromToken(key);
          return key;
        } else {
          return 'noKey';
        }
      } catch (error) {
        print(error);
        return 'noKey';
      }
    } else {
      return userKey!;
    }
  }

  static Future<void> resetUserKey() async {
    if (userKey == null) {
      return;
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/usrToken.txt');
      file.exists().then((exists) {
        file.exists().then((exists) {
          if (exists) {
            file.delete();
          }
        });
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _setUserKey(String rawKey) async {
    final dir = await getApplicationDocumentsDirectory();
    String key = jsonDecode(rawKey)['key'];
    User.buildFromToken(key);
    try {
      final file = File('${dir.path}/usrToken.txt');
      file.writeAsString(key);
    } catch (error) {
      print('error saving key file');
    }
  }

  static Future<Environment> _getUserEnvironment() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      final file = File('${dir.path}/env.txt');
      if (await file.exists()) {
        int intEnv = int.tryParse(file.readAsStringSync()) ?? 0;
        DefaultURL.env = Environment.values[intEnv];
        print('environment setted ${DefaultURL.env}!');
      } else {
        print('no environment set!');
      }
    } catch (error) {
      print('no environment set!');
    }
    return DefaultURL.env; // Environment.prod;
  }

  static Future<void> _resetUserEnvironment() async {
    final dir = await getApplicationDocumentsDirectory();
    // DefaultURL.env = Environment.prod;
    try {
      final file = File('${dir.path}/env.txt');
      file.exists().then((exists) {
        if (exists) {
          file.delete();
        }
      });
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

  Future<Options> getOptionsRequest({String? method}) async {
    Map<String, String> headers = {
      Headers.acceptHeader: 'application/json',
      Headers.contentTypeHeader: 'application/json'
    };

    String key = await getUserKey();

    if (key != '' && key != 'noKey') {
      headers[Headers.wwwAuthenticateHeader] = 'jwt $key';
    }

    // Set default configs
    dio.options.baseUrl = this.baseURL + this.baseURI;
    dio.options.connectTimeout = DefaultURL.defaultTimeout();
    dio.options.receiveTimeout = DefaultURL.defaultTimeout();

    Options opts = Options(
      headers: headers,
      method: method == null ? 'GET' : method,
    );

    return opts;
  }

  Future<Return> getContent(String service) async {
    try {
      Options opts = await getOptionsRequest();
      log("Chamando getContent [$service]");
      Response response = await dio.get(service, options: opts);
      log("Finalizando getContent [$service] HTTP CODE ${response.statusCode}");
      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
        returnObject: response.data,
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> getContentWithParams(
      String service, Map<String, String> params) async {
    try {
      Options opts = await getOptionsRequest();
      log("Chamando getContent [$service]");
      String url = service + parseParams(params);
      Response response = await dio.get(url, options: opts);
      log("Finalizando getContent [$service] HTTP CODE ${response.statusCode}");

      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> putContentWithBody(String service, String body) async {
    try {
      Options opts = await getOptionsRequest(method: 'PUT');
      log("Chamando putContentWithBody [$service]");
      Response response = await dio.request(service, data: body, options: opts);
      log("Finalizando putContentWithBody [$service] HTTP CODE ${response.statusCode}");

      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> postContentWithBody(String service, String body) async {
    try {
      Options opts = await getOptionsRequest(method: 'POST');
      log("Chamando postContentWithBody [$service]");
      Response response = await dio.request(service, data: body, options: opts);
      log("Finalizando postContentWithBody [$service] HTTP CODE ${response.statusCode}");

      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> postContentWithParams(
      String service, Map<String, String> params, String body) async {
    try {
      Options opts = await getOptionsRequest(method: 'POST');
      log("Chamando postContentWithParams [$service]");
      String url = service + parseParams(params);
      Response response = await dio.request(url, data: body, options: opts);
      log("Finalizando postContentWithParams [$service] HTTP CODE ${response.statusCode}");

      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> deleteContent(String service) async {
    try {
      Options opts = await getOptionsRequest(method: 'DELETE');
      log("Chamando postContentWithParams [$service]");
      Response response = await dio.request(service, options: opts);
      log("Finalizando postContentWithParams [$service] HTTP CODE ${response.statusCode}");
      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<Return> loginWithParams(Login input) async {
    try {
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
          env = DefaultURL.env; // Pega o que esta setado no config!
          break;
      }

      Options opts = await getOptionsRequest(method: 'POST');

      log("Chamando loginWithParams");

      final body = {
        'email': input.filteredLogin()!.trim().toLowerCase(),
        'senha': input.password!.trim(),
        'deviceToken': await getDeviceToken()
      };

      Response response =
          await dio.request('/api/v1/autenticacao', options: opts, data: body);
      log("Finalizando loginWithParams HTTP CODE ${response.statusCode}");

      if (response.statusCode! < 400) {
        await Connector._setUserEnvironment(env);
        await _setUserKey(jsonEncode(response.data));
        await User.fetch();
      }

      return Return(
        responseCode: response.statusCode,
        returnBody: jsonEncode(response.data),
      );
    } on DioError catch (e) {
      return Return(
        responseCode: e.response!.statusCode,
        returnBody: jsonEncode(e.response!.data),
      );
    } on Exception catch (_) {
      return Return(
        responseCode: 0,
        returnBody: jsonEncode({'message': 'Erro inesperado'}),
      );
    }
  }

  Future<bool> hasKey() async {
    await Connector._getUserEnvironment();
    String key = await getUserKey();
    return (key != 'noKey' && key != '');
  }

  static Future<void> logout() async {
    await Connector.resetUserKey();
    await Connector._resetUserEnvironment();

    User.instance = null;

    LoggedInNotifierService().setLogged(false);
  }
}
