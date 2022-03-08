import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Purchase.dart';
import 'package:afarma/model/User.dart';
import 'package:flutter/foundation.dart';

class PurchaseRepository extends ChangeNotifier {
  static final PurchaseRepository _manager = PurchaseRepository._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory PurchaseRepository() {
    return _manager;
  }

  PurchaseRepository._initializer();

  List<Purchase> _purchases = [];
  List<Purchase> get purchases => _purchases;

  void addPurchase(Purchase purchase) {
    if (!_purchases.contains(purchase)) refreshPurchases();
  }

  Future<List<Purchase>> fetchPurchases() async {
    await refreshPurchases();
    return _purchases;
  }

  Future<List<Purchase>> refreshPurchases() async {
    if (User.instance == null) {
      return [];
    }
    _purchases = [];
    notifyListeners();
    final resp = await _connector
        .getContent('/api/v1/Pedido/byCliente/${User.instance!.id}');
    _purchases = Purchase.fromJSONList(resp.returnBody!);
    notifyListeners();
    return _purchases;
  }

  void clear() {
    _purchases.clear();
  }
}
