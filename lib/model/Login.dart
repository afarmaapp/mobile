class Login {
  static const List<String> _modifiers = ['+dev', '+hom'];

  Login({this.login, this.password, this.deviceToken});

  String? login = '';
  String? password = '';
  String? deviceToken = '';
  bool loginLock = false;

  String loginModifier() {
    if (login != null) {
      return _modifiers.firstWhere((modifier) => login!.contains(modifier),
          orElse: () => '');
    } else {
      return '';
    }
  }

  String? filteredLogin() {
    if (login != null) {
      for (String modifier in _modifiers) {
        if (login!.contains(modifier)) return login!.replaceAll(modifier, '');
      }
      return login;
    }
    return '';
  }

  bool canLogin() {
    return (login != null && login != '' && password != null && password != '');
  }

  void clear() {
    login = '';
    password = '';
  }
}
