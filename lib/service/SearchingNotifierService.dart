import 'package:flutter/cupertino.dart';

class SearchingNotifierService extends ChangeNotifier {
  static final SearchingNotifierService _manager =
      SearchingNotifierService._initializer();

  SearchingNotifierService._initializer();

  factory SearchingNotifierService() {
    return _manager;
  }

  bool _searching = false;
  bool get searching => _searching;

  void setSearching(bool newSearching) {
    this._searching = newSearching;
    notifyListeners();
  }
}
