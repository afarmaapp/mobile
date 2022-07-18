import 'package:flutter/cupertino.dart';

class LoggedInNotifierService extends ChangeNotifier {
  static final LoggedInNotifierService _manager =
      LoggedInNotifierService._initializer();

  LoggedInNotifierService._initializer();

  factory LoggedInNotifierService() {
    return _manager;
  }

  bool _logged = false;
  bool get logged => _logged;

  void setLogged(bool newLogged) {
    this._logged = newLogged;
    notifyListeners();
  }
}
