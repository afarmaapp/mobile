// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ean: json['ean'] as String,
      principioAtivo: json['principio_ativo'] as String,
      valor: (json['valor'] as num).toDouble(),
      valorRaia: (json['valor_raia'] as num?)?.toDouble(),
      valorCompra: (json['valor_compra'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'ean': instance.ean,
      'principioAtivo': instance.principioAtivo,
      'valor': instance.valor,
      'valorRaia': instance.valorRaia,
      'valorCompra': instance.valorCompra,
    };
