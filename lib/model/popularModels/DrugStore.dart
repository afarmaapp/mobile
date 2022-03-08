import 'package:afarma/model/popularModels/DrugStoreEmployee.dart';
import 'package:afarma/model/popularModels/Address.dart';

class DrugStore {
  DrugStore(
      {this.id,
      this.name,
      this.pharmaceutical,
      this.sellers,
      this.delivery,
      this.cnpj,
      this.address,
      this.phoneNumbers});

  final String? id;
  final String? name;
  final DrugStoreEmployee? pharmaceutical;
  final List<DrugStoreEmployee>? sellers;
  final List<DrugStoreEmployee>? delivery;
  final String? cnpj;
  final Address? address;
  final List<String>? phoneNumbers;

  factory DrugStore.fromJSON(Map<String, dynamic>? json) {
    if (json == null) return DrugStore();
    return DrugStore(
        id: (json['id'] ?? '') as String,
        name: (json['nomeFantasia'] ?? '') as String,
        pharmaceutical: DrugStoreEmployee.fromJSON(json['farmaceutico']),
        sellers: _sellersFromJSON(json),
        delivery: _deliveryFromJSON(json),
        cnpj: (json['cnpj'] ?? '') as String,
        address: Address.fromJSON(json['endereco']),
        phoneNumbers: _phoneNumbersFromJSON(json));
  }

  static List<DrugStoreEmployee> _sellersFromJSON(Map<String, dynamic> json) {
    List? sellersList = json['vendedores'];
    return DrugStoreEmployee.fromJSONList(sellersList);
  }

  static List<DrugStoreEmployee> _deliveryFromJSON(Map<String, dynamic> json) {
    List? deliveryList = json['entregadores'];
    return DrugStoreEmployee.fromJSONList(deliveryList);
  }

  static List<String> _phoneNumbersFromJSON(Map<String, dynamic> json) {
    List? numbers = json['telefones'];
    List<String> ret = [];
    if (numbers != null) {
      numbers.forEach((number) {
        String ddd = number['ddd'] ?? '21';
        String num = number['numero'] ?? '';
        ret.add('($ddd) $num');
      });
    }
    return ret;
  }
}
