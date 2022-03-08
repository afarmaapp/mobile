import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Purchase.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/foundation.dart';

class PurchaseManager extends ChangeNotifier {
  static final PurchaseManager _manager = PurchaseManager._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory PurchaseManager() {
    return _manager;
  }

  PurchaseManager._initializer();

  List<Purchase> _purchases = [];
  List<Purchase> get purchases => _purchases;

  void addPurchase(Purchase purchase) {
    if (!_purchases.contains(purchase)) refreshPurchases();
  }

  Future<List<Purchase>> fetchPurchases() async {
    if (_purchases == null || _purchases.length == 0)
      return await refreshPurchases();
    notifyListeners();
    return _purchases;
  }

  Future<List<Purchase>> refreshPurchases() async {
    _purchases = [];
    notifyListeners();
    final resp = await _connector
        .getContent('/api/v1/Pedido/byCliente/${User.instance?.id}');
    _purchases = Purchase.fromJSONList(resp.returnBody!);
    notifyListeners();
    return _purchases;
  }

  void clear() {
    _purchases.clear();
  }
}
