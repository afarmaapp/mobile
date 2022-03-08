import 'dart:convert';
import 'dart:io';

import 'package:afarma/model/popularModels/Address.dart';
import 'package:afarma/model/popularModels/DrugStore.dart';
import 'package:afarma/repository/popularRepositories/Cart.dart';
import 'package:afarma/repository/popularRepositories/PurchaseManager.dart';
import 'package:afarma/repository/popularRepositories/Recipe.dart';
import 'package:equatable/equatable.dart';

class Purchase extends Equatable {
  Purchase(
      {this.id,
      this.crm,
      this.recipe,
      this.items,
      this.status,
      this.deliveryAddress,
      this.date,
      this.drugStore,
      //ALTERAÇAO ELIZIER
      this.motivoRejeicao,
      this.origemPedido});

  final String? id;
  final String? crm;
  final Recipe? recipe;
  final PurchaseCart? items;
  final String? status;
  final Address? deliveryAddress;
  final DateTime? date;
  final DrugStore? drugStore;
  //ALTERAÇAO ELIZIER
  final String? motivoRejeicao;
  final String? origemPedido;

  static List<Purchase> fromJSONList(String jsonList) {
    List<Purchase> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Purchase.fromJSON(json)));
    return ret;
  }

  factory Purchase.fromJSON(Map<String, dynamic> json) {
    int index = PurchaseManager()
        .purchases
        .indexWhere((purchase) => purchase.id == json['id'] as String?);
    if (index != -1) {
      return PurchaseManager().purchases[index];
    }
    Purchase purchase = Purchase(
      id: (json['id'] ?? '') as String,
      crm: (json['crm'] ?? '') as String,
      items: PurchaseCart.fromJSON(json['cesta'] ?? '' as Map<String, dynamic>),
      status: (json['status'] ?? '') as String,
      deliveryAddress: Address.fromJSON(
          json['enderecoEntrega'] ?? '' as Map<String, dynamic>?),
      date: _getDateFromJSON(json),
      drugStore: DrugStore.fromJSON(json['lojaAtendimento']),
      //ALTERAÇAO ELIZIER
      motivoRejeicao: (json['motivoRejeicao'] ?? '') as String,
      origemPedido: _getOriginFromJSON(json),
    );
    return purchase;
  }

  static String? _getOriginFromJSON(Map<String, dynamic> json) {
    if (json.containsKey('origemPedido')) {
      return json['origemPedido'];
    }
    return Platform.isAndroid ? 'MOBILE_ANDROID' : 'MOBILE_IOS';
  }

  String formattedID() {
    List substrings = id!.split('-');
    return substrings.first ?? '0';
  }

  String formattedStatus() {
    String result = '';
    switch (status) {
      default:
        result = _formatStatus();
    }
    //Alteração feita por Elizier
    switch (result) {
      case 'Entregue':
        return 'Saindo para entrega';
      case 'Aberto':
        return 'Erro na geração, favor entrar em contato';
    }
    if (result == 'Entregue') {
      return 'Saindo para entrega';
    }
    return result;
  }

  String _formatStatus() {
    if (status == null) return '';
    String? statusString = status;
    if (status!.contains('_')) statusString = status!.replaceAll('_', ' ');
    String first = statusString!.substring(0, 1);
    String last = statusString.substring(1);
    return first.toUpperCase() + last.toLowerCase();
  }

  static DateTime _getDateFromJSON(Map<String, dynamic> json) {
    dynamic dateFromJSON = json['dataPedido'];
    DateTime? date;
    if (dateFromJSON is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateFromJSON);
    } else if (dateFromJSON is String) {
      date = DateTime.tryParse(dateFromJSON);
    }
    return date ?? DateTime.now();
  }

  @override
  List<Object?> get props => [id];
}
