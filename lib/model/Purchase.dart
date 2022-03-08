import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:afarma/page/purchase/CompletePurchasePage.dart';
import 'package:afarma/repository/PurchaseRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'Address.dart';
import 'Cart.dart';
import 'DrugStore.dart';
// import 'Recipe.dart';

class Purchase extends Equatable {
  Purchase({
    required this.id,
    this.crm,
    // this.recipe,
    this.items,
    this.status,
    this.deliveryAddress,
    this.date,
    this.drugStore,
    this.motivoRejeicao,
    this.origemPedido,
    this.formaPagamento,
    this.troco,
    this.valorTotalDoPedido,
    this.observacao,
  });

  final String? id;
  final String? crm;
  // final Recipe? recipe;
  final PurchaseCart? items;
  final String? status;
  final Address? deliveryAddress;
  final DateTime? date;
  final DrugStore? drugStore;
  final String? motivoRejeicao;
  final String? origemPedido;
  final FormaPagamento? formaPagamento;
  final double? troco;
  final double? valorTotalDoPedido;
  final String? observacao;

  static List<Purchase> fromJSONList(String jsonList) {
    List<Purchase> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Purchase.fromJSON(json)));
    return ret;
  }

  factory Purchase.fromJSON(Map<String, dynamic> json) {
    int index = PurchaseRepository()
        .purchases
        .indexWhere((purchase) => purchase.id == json['id'] as String);
    if (index != -1) {
      return PurchaseRepository().purchases[index];
    }

    log("Pedido " + json['id'] + " carregado");

    Purchase purchase = Purchase(
      id: (json['id'] ?? '') as String,
      items: PurchaseCart.fromJSON(json['cesta'] ?? ''),
      status: (json['status'] ?? '') as String,
      deliveryAddress: Address.fromJSON(json['enderecoEntrega'] ?? ''),
      date: _getDateFromJSON(json),
      motivoRejeicao: (json['motivoRejeicao'] ?? '') as String,
      origemPedido: _getOriginFromJSON(json),
      formaPagamento: json['formaPagamento'] != null
          ? FormaPagamento.values.firstWhere(
              (e) => e.toString() == 'FormaPagamento.' + json['formaPagamento'])
          : null,
      troco: (json['troco'] ?? 0.0) as double,
      valorTotalDoPedido: (json['valorTotalDoPedido'] ?? 0.0) as double,
      observacao: (json['observacao'] ?? '') as String,
    );
    return purchase;
  }

  String getTrocoString(String prefixString, String sufixString) {
    if (this.troco != null && this.troco != 0.0) {
      var valorMaskControlller = MoneyMaskedTextController(
          decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
      valorMaskControlller.updateValue(this.troco!);
      return prefixString + valorMaskControlller.text + sufixString;
    }
    return "";
  }

  String getValorTotalDoPedidoString() {
    var valorMaskControlller = MoneyMaskedTextController(
        decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
    valorMaskControlller.updateValue(this.valorTotalDoPedido!);
    return valorMaskControlller.text;
  }

  static String _getOriginFromJSON(Map<String, dynamic> json) {
    if (json.containsKey('origemPedido')) {
      return json['origemPedido'];
    }
    return Platform.isAndroid ? 'MOBILE_ANDROID' : 'MOBILE_IOS';
  }

  String getStringFormaPagamento() {
    if (this.formaPagamento == null) {
      return "Não Informado";
    }

    if (formaPagamento == FormaPagamento.DINHEIRO) {
      return "Dinheiro";
    } else if (formaPagamento == FormaPagamento.CARTAO_CREDITO) {
      return "Cartão de Crédito";
    } else if (formaPagamento == FormaPagamento.CARTAO_DEBITO) {
      return "Cartão de Débito";
    } else if (formaPagamento == FormaPagamento.PIX) {
      return "PIX";
    } else {
      return "Não Informado";
    }
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
    String statusString = status!;
    if (status!.contains('_')) statusString = status!.replaceAll('_', ' ');
    String first = statusString.substring(0, 1);
    String last = statusString.substring(1);
    return first.toUpperCase() + last.toLowerCase();
  }

  static DateTime _getDateFromJSON(Map<String, dynamic> json) {
    dynamic dateFromJSON = json['dataPedido'];
    DateTime? date;
    if (dateFromJSON is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateFromJSON);
    } else if (dateFromJSON is String) {
      date = DateTime.tryParse(dateFromJSON)!;
    }
    return date ?? DateTime.now();
  }

  @override
  List<Object> get props => [id!];
}
