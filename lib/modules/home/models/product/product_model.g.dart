// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tarja: json['tarja'] as String,
      ean: json['ean'] as String,
      principioAtivo: json['principio_ativo'] as String,
      valor: (json['valor'] as num).toDouble(),
      concorrentes: (json['valor_concorrente'] as List<dynamic>?)
          ?.map((e) => Competitor.fromJson(e as Map<String, dynamic>))
          .toList(),
      produtoSimilar: (json['produto_similar'] as List<dynamic>?)
          ?.map((e) => SimilarProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      valorCompra: (json['valor_compra'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'tarja': instance.tarja,
      'ean': instance.ean,
      'principioAtivo': instance.principioAtivo,
      'valor': instance.valor,
      'concorrentes': instance.concorrentes,
      'produtoSimilar': instance.produtoSimilar,
      'valorCompra': instance.valorCompra,
    };
