import 'dart:convert';

import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/User.dart';
import 'package:flutter/foundation.dart';

class AddressRepository extends ChangeNotifier {
  static final AddressRepository _manager = AddressRepository._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory AddressRepository() {
    return _manager;
  }

  AddressRepository._initializer();

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;
  bool? _selectedAddressIsCurrentLocation;
  bool? get selectedAddressIsCurrentLocation =>
      _selectedAddressIsCurrentLocation;

  Future<List<Address>?> getAllAddresses() async {
    if (_addresses != null && _addresses.length > 0) return _addresses;
    final resp = await _connector
        .getContent('/api/v1/Usuario/${User.instance!.id}/enderecos');
    if (resp.responseCode! < 400) {
      _addresses = Address.fromJSONList(resp.returnBody);
      notifyListeners();
    }
    return null;
  }

  void selectAddress(Address address, bool isCurrent) {
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
    _selectedAddressIsCurrentLocation = null;
    notifyListeners();
  }
}
