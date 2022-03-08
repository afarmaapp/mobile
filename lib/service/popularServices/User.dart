import 'dart:convert';

import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Address.dart';

class User {
  User(
      {this.id,
      this.name,
      this.email,
      this.cellphone,
      this.cpf,
      this.codigoInd,
      this.docIDs,
      this.addresses});

  static User? instance;

  String? id;
  String? name;
  String? email;
  String? cellphone;
  String? cpf;
  String? codigoInd;
  List<String?>? docIDs;
  List<Address>? addresses;

  String firstName() {
    List<String> splitted = name!.split(' ');
    return splitted.first;
  }

  static void buildFromToken(String? key) {
    Map<String, dynamic> json = parseJWTToken(key)!;
    User.instance = User(
      id: json['identity'] as String?,
      name: (json['name'] as String?),
      email: (json['params'] as Map<String, dynamic>)['Email'] as String?,
      cellphone:
          (json['params'] as Map<String, dynamic>)['Telefone'] as String?,
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
        id: (json['id'] as int?).toString(),
        name: json['nome'] as String?,
        email: json['email'] as String?,
        cellphone: json['telefone'] as String?,
        cpf: json['cpf'] as String?,
        codigoInd: (json['codigoInd'] as String?),
        docIDs: _getDocIDS(json),
        addresses: _getAddresses(json));
  }

  static List<String?> _getDocIDS(Map<String, dynamic> json) {
    List? docs = json['documentos'];
    if (docs == null) return [];
    List<String?> ret = [];
    docs.forEach((doc) => ret.add(doc['id']));
    return ret;
  }

  static List<Address> _getAddresses(Map<String, dynamic> json) {
    List? addr = json['enderecos'];
    if (addr == null) return [];
    List<Address> ret = [];
    addr.forEach((address) => ret.add(Address.fromJSON(address)));
    return ret;
  }

  static Future<void> fetch() async {
    final c =
        Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
    final resp = await c.getContent('/api/v1/Usuario/${User.instance!.id}');
    if (resp.responseCode! < 400) {
      User newData = User.fromJSON(jsonDecode(resp.returnBody!));
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
    User.instance!.cpf = usr.cpf;
    User.instance!.codigoInd = usr.codigoInd;
    User.instance!.docIDs = usr.docIDs;
    User.instance!.addresses = usr.addresses;
  }
}
