import 'dart:convert';

import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Address.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/foundation.dart';

class AddressManager extends ChangeNotifier {
  static final AddressManager _manager = AddressManager._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory AddressManager() {
    return _manager;
  }

  AddressManager._initializer();

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;
  bool? _selectedAddressIsCurrentLocation;
  bool? get selectedAddressIsCurrentLocation =>
      _selectedAddressIsCurrentLocation;

  Future<List<Address>> getAllAddresses() async {
    if (_addresses != [] && _addresses.length > 0) return _addresses;
    final resp = await _connector
        .getContent('/api/v1/Usuario/${User.instance!.id}/enderecos');
    if (resp.responseCode! < 400) {
      _addresses = Address.fromJSONList(resp.returnBody);
      _addresses = _addresses.toSet().toList();
      notifyListeners();
      return _addresses;
    }
    return _addresses;
    // return Address.fromJSONList(resp.returnBody);
  }

  void selectAddress(Address? address, bool? isCurrent) {
    _selectedAddress = address;
    _selectedAddressIsCurrentLocation = isCurrent;
    notifyListeners();
  }

  Future<int?> addAddress(Address address) async {
    final resp = await _connector.postContentWithBody(
        '/api/v1/Usuario/${User.instance!.id}/endereco', address.toJSON());
    if (resp.responseCode! < 400) {
      Map parsed = jsonDecode(resp.returnBody!);
      address.id = (parsed['id'] ?? '') as String;
      _addresses.clear();
      getAllAddresses();
    }
    return resp.responseCode;
  }

  Future<int?> removeAddress(Address address) async {
    final resp = await _connector.deleteContent(
        '/api/v1/Usuario/${User.instance!.id}/endereco/${address.id}');
    if (resp.responseCode! < 400) {
      _addresses.remove(address);
      notifyListeners();
    }
    return resp.responseCode;
  }

  void clear() {
    _addresses.clear();
    _selectedAddress = null;
    _selectedAddressIsCurrentLocation = false;
    notifyListeners();
  }
}
