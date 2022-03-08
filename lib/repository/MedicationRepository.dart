import 'dart:convert';

import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Medication.dart';
import 'package:afarma/model/Return.dart';
import 'package:flutter/foundation.dart';

import 'AddressRepository.dart';

class MedicationRepository extends ChangeNotifier {
  static final MedicationRepository _manager =
      MedicationRepository._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory MedicationRepository() {
    return _manager;
  }

  MedicationRepository._initializer();

  List<Medication> _meds = [];
  List<Medication> get meds => _meds;

  List<Medication> _medsPromo = [];
  List<Medication> get medsPromo => _medsPromo;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _hasMorePromo = true;
  bool get hasMorePromo => _hasMorePromo;

  String? _farmaciaPromocao;
  String? get farmaciaPromocao => _farmaciaPromocao;

  void addMedication(Medication med) {
    if (_meds == null || _meds.length == 0) {
      _meds = [med];
    } else {
      if (!_meds.contains(med)) _meds.add(med);
    }
  }

  Future<List<Medication>> fetchMedications(
      String? q, String? departamentoId, bool promo) async {
    if (promo) {
      // Se não tem os dados retorna vazio
      if (!hasPromocaoLatLon()) {
        this._hasMore = false;
        notifyListeners();
        return [];
      }
      return await _getMedicationsPromo(
        q,
        AddressRepository().selectedAddress!.position!.latitude.toString(),
        AddressRepository().selectedAddress!.position!.longitude.toString(),
      );
    } else {
      return await _getMedications(q, departamentoId);
    }
  }

  void cleanList() {
    _meds.clear();
    this._hasMore = true;
  }

  void cleanListPromo() {
    _medsPromo.clear();
    this._hasMore = true;
  }

  Future<dynamic?> cotar(List<Medication> meds, List<int> amounts) async {
    var list = [];

    for (var i = 0; i < meds.length; i++) {
      list.add({"ean": meds[i].ean, "quantidade": amounts[i].toString()});
    }

    var jsonString = jsonEncode(list);

    Return resp = await _connector.postContentWithBody(
        '/api/v1/ServicosPedidoCesta/cotar', jsonString);

    return jsonDecode(resp.returnBody!);
  }

  Future<dynamic?> cotarJSON(List<Medication> meds, List<int> amounts) async {
    var list = [];

    for (var i = 0; i < meds.length; i++) {
      list.add({"ean": meds[i].ean, "quantidade": amounts[i].toString()});
    }

    var jsonString = jsonEncode(list);

    Return resp = await _connector.postContentWithBody(
        '/api/v1/ServicosPedidoCesta/cotarJSON', jsonString);

    return jsonDecode(resp.returnBody!);
  }

  Future<List<Medication>> _getMedications(
      String? q, String? departamentoId) async {
    // Monta URL de busca
    String qUrl = 'null';
    if (q != null && q != '') {
      qUrl = '$q';
    }

    String departamentUrl = 'null';
    if (departamentoId != null && departamentoId != '') {
      departamentUrl = '$departamentoId';
    }

    String range = "0-9";
    if (_meds != null && _meds.length != 0) {
      String currentRegister = (_meds.length).toString();
      String lastPosRegister = ((_meds.length - 1) + 10).toString();

      range = currentRegister + "-" + lastPosRegister;
    }

    String finalUrl =
        '/api/v1/Produto/buscarProdutos/$qUrl/$departamentUrl/false?range=$range';

    final Return resp = await _connector.getContent(finalUrl);

    // Adiciona novos elementos
    List<Medication> listToAdd = Medication.fromJSONList(resp.returnBody!);
    if (listToAdd.length > 0) {
      _meds.addAll(listToAdd);
    } else {
      this._hasMore = false;
    }

    // Avisa todos que chegou mais regitro
    notifyListeners();

    return _meds;
  }

  void setFarmaciaPromocao(String? f) {
    _farmaciaPromocao = f;
  }

  bool hasPromocaoLatLon() {
    return AddressRepository().selectedAddress != null &&
        AddressRepository().selectedAddress!.position != null;
  }

  Future<List<Medication>> _getMedicationsPromo(
      String? q, String lat, String lon) async {
    String range = "0-9";

    if (_medsPromo != null && _medsPromo.length != 0) {
      String currentRegister = (_medsPromo.length).toString();
      String lastPosRegister = ((_medsPromo.length - 1) + 10).toString();

      range = currentRegister + "-" + lastPosRegister;
    }

    String f = 'null';
    if (farmaciaPromocao != null) {
      f = farmaciaPromocao!;
    }

    String finalUrl =
        '/api/v1/Promocao/produtosEmPromocaoLoja/$f/$lat/$lon?range=$range';

    final Return resp = await _connector.getContent(finalUrl);

    // Adiciona novos elementos
    List<Medication> listToAdd = Medication.fromJSONList(resp.returnBody!);
    if (listToAdd.length > 0) {
      _medsPromo.addAll(listToAdd);
    } else {
      this._hasMore = false;
    }

    // Avisa todos que chegou mais regitro
    notifyListeners();

    return _medsPromo;
  }
}
