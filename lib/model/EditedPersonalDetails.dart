import 'User.dart';

class EditedPersonalDetails {
  User? user;

  String? _oldName;
  String? _name;
  String? get name => _name;
  set name(String? newName) {
    if (_name != null) {
      _oldName = '$_name';
    }
    _name = newName;
  }

  String? _oldCPF;
  String? _cpf;
  String? get cpf => _cpf;
  set cpf(String? newCPF) {
    if (_cpf != null) {
      _oldCPF = '$_cpf';
    }
    _cpf = newCPF;
  }

  String? _oldPhone;
  String? _phone;
  String? get phone => _phone;
  set phone(String? newPhone) {
    if (_phone != null) {
      _oldPhone = '$_phone';
    }
    _phone = newPhone;
  }

  String? _oldEmail;
  String? _email;
  String? get email => _email;
  set email(String? newEmail) {
    if (_email != null) {
      _oldEmail = '$_email';
    }
    _email = newEmail;
  }

  String toJSON() {
    return '{ "nome": "$_name", "cpf": "${_cpf!.trim()}", "email": "${_email!.trim()}", "telefone": "${_phone!.trim()}"';
  }

  String changesToJSON() {
    String ret = '{ "id": "${user!.id}"';
    if (_oldName != null) {
      ret += ', "nome": "$_name"';
    }
    if (_oldCPF != null) {
      ret += ', "cpf": "$_cpf"';
    }
    if (_oldEmail != null) {
      ret += ', "email": "${_email!.trim()}"';
    }
    if (_oldPhone != null) {
      ret += ', "telefone": "$_phone"';
    }
    ret += ' }';
    return ret;
  }

  static EditedPersonalDetails fromUser(User? usr) {
    final ret = EditedPersonalDetails();
    ret.user = usr;
    ret.populateFromUser();
    return ret;
  }

  void populateFromUser() {
    _name = user!.name;
    _cpf = user!.cpf;
    _phone = user!.cellphone;
    _email = user!.email;
  }

  void applyChangesToUser() {
    if (_oldName != null) {
      user!.name = _name!;
    }
    if (_oldCPF != null) {
      user!.cpf = _cpf;
    }
    if (_oldEmail != null) {
      user!.email = _email!;
    }
    if (_oldPhone != null) {
      user!.cellphone = _phone!;
    }
  }

  bool hasChanges() {
    return _oldName != null ||
        _oldCPF != null ||
        _oldEmail != null ||
        _oldPhone != null;
  }

  bool canConfirm() {
    return name != null &&
        name!.trim().length > 0 &&
        cpf != null &&
        cpf!.trim().length == 11 &&
        phone != null &&
        phone!.trim().length > 0 &&
        email != null &&
        email!.contains('@');
  }
}
