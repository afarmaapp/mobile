import 'package:app/modules/cart/models/cart/cart_product_model.dart';
import 'package:app/modules/cart/models/cotation_item/cotation_item_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cotation_model.g.dart';

@JsonSerializable()
class Cotation {
  final String id;
  final List<CotationItem> itens;
  final String loja;
  final double total;

  Cotation({
    required this.id,
    required this.itens,
    required this.loja,
    required this.total,
  });

  factory Cotation.fromJson(Map<String, dynamic> json) =>
      _$CotationFromJson(json);

  Map<String, dynamic> toJson() => _$CotationToJson(this);
}
