import 'package:json_annotation/json_annotation.dart';

part 'similar_product_model.g.dart';

@JsonSerializable()
class SimilarProduct {
  final String id;
  final String ean;
  final String nome;
  final double valor;

  SimilarProduct({
    required this.id,
    required this.ean,
    required this.nome,
    required this.valor,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) =>
      _$SimilarProductFromJson(json);

  Map<String, dynamic> toJson() => _$SimilarProductToJson(this);
}
