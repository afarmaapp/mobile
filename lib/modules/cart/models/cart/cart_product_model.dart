import 'package:app/modules/home/models/product/product_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_product_model.g.dart';

@JsonSerializable()
class CartProduct {
  final Product product;
  final int qnt;

  CartProduct({
    required this.product,
    required this.qnt,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) =>
      _$CartProductFromJson(json);

  Map<String, dynamic> toJson() => _$CartProductToJson(this);
}
