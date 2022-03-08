import 'package:afarma/helper/Connector.dart';

import 'User.dart';

class PersonalDetails {
  String? name;
  String? cpf;
  String? phone;
  String? email;
  String? password;

  bool? acceptedTerms = false;

  Future<String> toJSONWithToken() async {
    final deviceToken = await Connector.getDeviceToken();

    // print('DeviceToken JSON with Token === $deviceToken');

    return '{ "nome": "$name", "cpf": "${cpf!.trim()}", "email": "${email!.trim()}", "telefone": "${phone!.trim()}", "deviceToken": "$deviceToken", "perfil": { "id": 2 } }';
  }

  void populateFromUser(User usr) {
    name = usr.name;
    cpf = usr.cpf;
    phone = usr.cellphone;
    email = usr.email;
  }

  bool canConfirm() {
    return name != null &&
        name!.trim().length > 0 &&
        cpf != null &&
        cpf!.trim().length == 11 &&
        phone != null &&
        phone!.trim().length > 0 &&
        email != null &&
        email!.contains('@') &&
        password != null;
  }
}
