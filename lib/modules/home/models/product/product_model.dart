import 'package:app/modules/home/models/competitors/competitors_model.dart';
import 'package:app/modules/home/models/similarProduct/similar_product_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String nome;
  final String? tarja;
  final String ean;
  final String principioAtivo;
  final double valor;
  final List<SimilarProduct> produtoSimilar;
  final List<Competitors> concorrentes;
  final double valorCompra;

  Product({
    required this.id,
    required this.nome,
    required this.tarja,
    required this.ean,
    required this.principioAtivo,
    required this.valor,
    required this.produtoSimilar,
    required this.concorrentes,
    required this.valorCompra,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
