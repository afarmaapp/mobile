import 'package:app/modules/cart/models/cart/cart_product_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cotation_item_model.g.dart';

@JsonSerializable()
class CotationItem {
  final String id;
  final String nome;
  final int quantidade;
  final double valor;
  final double total;

  CotationItem({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.valor,
    required this.total,
  });

  factory CotationItem.fromJson(Map<String, dynamic> json) =>
      _$CotationItemFromJson(json);

  Map<String, dynamic> toJson() => _$CotationItemToJson(this);
}
