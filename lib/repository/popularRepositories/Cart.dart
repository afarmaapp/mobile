import 'dart:convert';

import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Medication.dart';
import 'package:afarma/model/popularModels/Purchase.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/material.dart';

class Cart extends ChangeNotifier {
  static final Cart _cart = Cart._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory Cart() {
    return _cart;
  }

  Cart._initializer();

  List<Medication?>? _meds = [];
  List<Medication?>? get meds => _meds;

  List<int?>? _amounts = [];
  List<int?>? get amounts => _amounts;

  List<String> _itemIDs = [];

  String? _cartID;
  String? get cartID => _cartID;

  void addMedication(Medication? newMed, int? amount) {
    int medIndex = _meds!.indexOf(newMed);
    if (medIndex == -1) {
      _cartID = null;
      _meds!.add(newMed);
      _amounts!.add(amount);
    }
    notifyListeners();
  }

  void removeMed(Medication? med) {
    int index = _meds!.indexOf(med);
    if (index != -1) {
      _cartID = null;
      _meds!.removeAt(index);
      _amounts!.removeAt(index);
    }
    notifyListeners();
  }

  void repeatOrder(Purchase repeatPurchase) {
    _meds = repeatPurchase.items!.meds!.cast<Medication?>();
    _amounts = repeatPurchase.items!.amounts;
  }

  void changeMedAmount(Medication med, int newAmount) {
    return;
    int index = _meds!.indexOf(med);
    if (index != -1) {
      _amounts![index] = newAmount;
    }
    notifyListeners();
  }

  bool needsPayment() {
    return _meds!.indexWhere((element) => element!.needsPayment()) != -1;
  }

  double paymentAmount() {
    double ret = 0.0;
    if (needsPayment()) {
      int index = 0;
      _meds!.forEach((med) {
        if (med!.needsPayment()) {
          int medAmount = _amounts![index]!;
          ret += (med.price! * medAmount);
        }
        index++;
      });
    } else {
      return -1.0;
    }
    return ret;
  }

  void clear() {
    _cartID = null;
    _meds!.clear();
    _amounts!.clear();
    notifyListeners();
  }

  Future<String?> getCartID() async {
    if (_cartID != null) return _cartID;
    List<String> itemIDs = await _getItemIDs();
    String idString = '[ ';
    itemIDs.forEach((id) => idString += id);
    idString += ']';
    final resp = await _connector.postContentWithBody('/api/v1/Cesta',
        '{ "cliente": { "id": ${User.instance?.id} }, "data": "${DateTime.now().toIso8601String()}", "itens": $idString }');
    if (resp.responseCode! < 400) {
      Map<String, dynamic> parsedResp = jsonDecode(resp.returnBody!);
      _cartID = (parsedResp['id'] ?? '') as String;
    }
    return _cartID;
  }

  Future<List<String>> _getItemIDs() async {
    if (_itemIDs.length == _meds!.length) return _itemIDs;
    int index = 0;
    String body = '[ ';
    _meds!.forEach((med) {
      body += _medToCartMed(index);
      if (index != _meds!.length - 1) {
        body += ', ';
      } else {
        body += ']';
      }
      index++;
    });
    final resp = await _connector.postContentWithBody(
        '/api/v1/ItemProdutoCesta/persistList', body);
    if (resp.responseCode! < 400) {
      _itemIDs.clear();
      List parsedResp = jsonDecode(resp.returnBody!);
      int index = 0;
      parsedResp.forEach((item) {
        String id = (item['id'] ?? '') as String;
        String toAddString = '{ "id": "$id" }';
        if (index != parsedResp.length - 1) {
          toAddString += ', ';
        }
        _itemIDs.add(toAddString);
        index++;
      });
    }
    return _itemIDs;
  }

  String _medToCartMed(int index) {
    Medication med = _meds![index]!;
    int? amount = _amounts![index];
    return '{ "produto": ${med.toJSON()}, "quantidade": $amount }';
  }

  PurchaseCart toPurchaseCart() {
    return new PurchaseCart(
        meds: List<Medication>.from(_meds!),
        amounts: List<int>.from(_amounts!));
  }
}

class PurchaseCart {
  PurchaseCart({this.meds, this.amounts});

  final List<Medication?>? meds;
  final List<int?>? amounts;

  factory PurchaseCart.fromJSON(Map<String, dynamic> json) {
    if (json == null) return PurchaseCart();
    List itemList = json['itens'] as List;
    return PurchaseCart(
        meds: _medsFromList(itemList), amounts: _amountsFromList(itemList));
  }

  static List<Medication> _medsFromList(List itemList) {
    List<Medication> ret = [];
    itemList.forEach((item) => ret.add(Medication.fromJSON(item['produto'])));
    return ret;
  }

  static List<int?> _amountsFromList(List itemList) {
    List<int?> ret = [];
    itemList.forEach((item) => ret.add(item['quantidade'] as int?));
    return ret;
  }
}
