import 'dart:collection';
import 'dart:convert';

import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Purchase.dart';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import 'Medication.dart';
import 'User.dart';

class Cart extends ChangeNotifier {
  static final Cart _cart = Cart._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory Cart() {
    return _cart;
  }

  Cart._initializer();

  List<Medication> _meds = [];
  List<Medication> get meds => _meds;

  List<int> _amounts = [];
  List<int> get amounts => _amounts;

  List<bool> _promo = [];
  List<bool> get promo => _promo;

  List<String> _itemIDs = [];

  String? _cartID;
  String? get cartID => _cartID;

  double? _cartValue;
  double? get cartValue => _cartValue;

  double? _lowerValue;
  double? get lowerValue => _lowerValue;

  void addMedication(Medication newMed, int amount, {bool promo = false}) {
    int medIndex = _meds.indexOf(newMed);
    if (medIndex == -1) {
      _cartID = null;
      _meds.add(newMed);
      _amounts.add(amount);
      _promo.add(promo);
    }
    notifyListeners();
  }

  void removeMed(Medication med) {
    int index = _meds.indexOf(med);
    if (index != -1) {
      _cartID = null;
      _meds.removeAt(index);
      _amounts.removeAt(index);
      _promo.removeAt(index);

      // Remove restrição de promoção
      // Se estou removendo um remédio da cesta eu verifico se ele adicionava a
      // restrição da promoção, se sim tem que verificar se não existem mais
      // remédios com esta restrição, e se sim remove a retrição
      if (med.lojaPromocao != null &&
          med.lojaPromocao != '' &&
          med.lojaPromocao == MedicationRepository().farmaciaPromocao) {
        // Somente remove a restrição se não existirem outros produtos com esta promoção
        if (_meds
            .where((element) => element.lojaPromocao == med.lojaPromocao)
            .isEmpty) {
          MedicationRepository().setFarmaciaPromocao(null);
        }
      }
    }
    notifyListeners();
  }

  void repeatOrder(Purchase repeatPurchase) {
    _meds = repeatPurchase.items!.meds;
    _amounts = repeatPurchase.items!.amounts;
  }

  double paymentAmount() {
    double ret = 0.0;

    int index = 0;
    _meds.forEach((med) {
      int medAmount = _amounts[index];
      ret += (med.precoMedio * medAmount);
      index++;
    });

    return ret;
  }

  String paymentAmountFormated() {
    double ret = paymentAmount();

    var valorMaskControlller = MoneyMaskedTextController(
        decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
    valorMaskControlller.updateValue(ret);
    return valorMaskControlller.text;
  }

  void clear() {
    // Retira a restrição de promoção
    MedicationRepository().setFarmaciaPromocao(null);

    _cartID = null;
    _meds.clear();
    _amounts.clear();
    _promo.clear();
    notifyListeners();
  }

  Future<String?> getCartID() async {
    if (_cartID != null) return _cartID;
    List<String> itemIDs = await _getItemIDs();
    String idString = '[ ';
    itemIDs.forEach((id) => idString += id);
    idString += ']';

    String body =
        '{ "cliente": { "id": "${User.instance?.id}" }, "data": "${DateTime.now().toIso8601String()}", "itens": $idString }';

    final resp = await _connector.postContentWithBody('/api/v1/Cesta', body);
    if (resp.responseCode! < 400) {
      Map<String, dynamic> parsedResp = jsonDecode(resp.returnBody!);
      _cartID = (parsedResp['id'] ?? '') as String;
      _cartValue = (parsedResp['valorTotalDaCesta'] ?? 0.0) as double;
    }

    MedicationRepository().cotar(_meds, _amounts).then((response) {
      dynamic comparatives = response;
      String comparativesStringTest = jsonEncode(comparatives);

      for (LinkedHashMap<String, dynamic> comparative in comparatives) {
        if (comparative["loja"] == "aFarma") {
          double val = double.tryParse(comparative["total"].toString()) ?? 0.0;

          _lowerValue = val;
        }
      }
    });

    return _cartID;
  }

  Future<List<String>> _getItemIDs() async {
    if (_itemIDs.length == _meds.length) return _itemIDs;
    int index = 0;
    String body = '[ ';
    _meds.forEach((med) {
      body += _medToCartMed(index);
      if (index != _meds.length - 1) {
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
    Medication med = _meds[index];
    int amount = _amounts[index];
    bool promo = _promo[index];
    return '{ "produto": ${med.toJSON()}, "quantidade": $amount, "produtoPromocao": ${promo ? med.toJSON() : null} }';
  }

  PurchaseCart toPurchaseCart() {
    return new PurchaseCart(
      meds: List<Medication>.from(_meds),
      amounts: List<int>.from(_amounts),
      // promo: List<bool>.from(_promo),
    );
  }
}

class PurchaseCart {
  PurchaseCart({
    required this.meds,
    required this.amounts,
    // required this.promo,
  });

  final List<Medication> meds;
  final List<int> amounts;
  // final List<bool> promo;

  factory PurchaseCart.fromJSON(Map<String, dynamic> json) {
    List itemList = json['itens'] as List;
    return PurchaseCart(
      meds: _medsFromList(itemList),
      amounts: _amountsFromList(itemList),
      // promo: _promoFromList(itemList),
    );
  }

  static List<Medication> _medsFromList(List itemList) {
    List<Medication> ret = [];
    itemList.forEach((item) => ret.add(Medication.fromJSON(item['produto'])));
    return ret;
  }

  static List<int> _amountsFromList(List itemList) {
    List<int> ret = [];
    itemList.forEach((item) => ret.add(item['quantidade'] as int));
    return ret;
  }

  // static List<bool> _promoFromList(List itemList) {
  //   List<bool> ret = [];
  //   itemList.forEach(
  //       (item) => item['produtoPromocao'] ? ret.add(true) : ret.add(false));
  //   return ret;
  // }
}
