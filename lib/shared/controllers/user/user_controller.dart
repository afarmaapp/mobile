import 'dart:convert';

import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/shared/models/user/user_model.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

part 'user_controller.g.dart';

class UserController = _UserControllerBase with _$UserController;

abstract class _UserControllerBase with Store {
  final c = Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  @observable
  User? user;

  @action
  buildFromToken(String key) {
    if (key == "") return;
    Map<String, dynamic> json = parseJWTToken(key)!;
    user = User(
      id: json['identity'] as String,
      nome: (json['name'] as String),
      email: (json['params'] as Map<String, dynamic>)['Email'] as String,
      telefone: (json['params'] as Map<String, dynamic>)['Telefone'] as String,
    );
  }

  @action
  parseJWTToken(String? token) {
    if (token == null) {
      return null;
    }
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    return payloadMap;
  }

  @action
  fetch() async {
    final loginController = GetIt.I.get<LoginController>();

    if (user == null) {
      if (await c.hasKey()) {
        loginController.logged == Logged.logged;
        buildFromToken(await c.getUserKey());
      } else {
        return;
      }
    }

    final resp = await c.getContent('/api/v1/Usuario/${user!.id}');
    if (resp.responseCode! < 400) {
      Map<String, dynamic> a = resp.returnObject!;
      user = User.fromJson(a);
      loginController.logged == Logged.logged;
    } else {
      print(
          'Error fetching user data, code: ${resp.responseCode}, body: ${resp.returnBody}');
    }
  }
}
