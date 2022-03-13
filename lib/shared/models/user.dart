// ignore_for_file: file_names

import 'dart:convert';

import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.cellphone,
  });

  static User? instance;

  String id;
  String name;
  String email;
  String cellphone;

  String firstName() {
    List<String> splitted = name.split(' ');
    return splitted.first;
  }

  static void buildFromToken(String key) {
    if (key == "") return;
    Map<String, dynamic> json = parseJWTToken(key)!;
    User.instance = User(
      id: json['identity'] as String,
      name: (json['name'] as String),
      email: (json['params'] as Map<String, dynamic>)['Email'] as String,
      cellphone: (json['params'] as Map<String, dynamic>)['Telefone'] as String,
    );
  }

  static Map<String, dynamic>? parseJWTToken(String? token) {
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
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      id: (json['id']).toString(),
      name: json['nome'] as String,
      email: json['email'] as String,
      cellphone: json['telefone'] as String,
    );
  }

  static Future<void> fetch() async {
    if (User.instance == null) return;

    final c =
        Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
    final resp = await c.getContent('/api/v1/Usuario/${User.instance!.id}');
    if (resp.responseCode! < 400) {
      Map<String, dynamic> a = resp.returnObject!;
      User newData = User.fromJSON(a);
      return _updateInstance(newData);
    } else {
      print(
          'Error fetching user data, code: ${resp.responseCode}, body: ${resp.returnBody}');
    }
  }

  static void _updateInstance(User usr) {
    if (User.instance == null) {
      User.instance = usr;
      return;
    }
    User.instance!.id = usr.id;
    User.instance!.name = usr.name;
    User.instance!.email = usr.email;
    User.instance!.cellphone = usr.cellphone;
  }
}
