import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String nome;
  final String ean;
  final String principioAtivo;
  final double valor;
  final double? valorRaia;
  final double valorCompra;

  Product({
    required this.id,
    required this.nome,
    required this.ean,
    required this.principioAtivo,
    required this.valor,
    required this.valorRaia,
    required this.valorCompra,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
