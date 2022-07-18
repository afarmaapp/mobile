// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarProduct _$SimilarProductFromJson(Map<String, dynamic> json) =>
    SimilarProduct(
      id: json['id'] as String,
      ean: json['ean'] as String,
      nome: json['nome'] as String,
      valor: (json['valor'] as num).toDouble(),
    );

Map<String, dynamic> _$SimilarProductToJson(SimilarProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ean': instance.ean,
      'nome': instance.nome,
      'valor': instance.valor,
    };
