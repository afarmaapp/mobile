// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotation_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CotationItem _$CotationItemFromJson(Map<String, dynamic> json) => CotationItem(
      id: json['id'] as String,
      nome: json['nome'] as String,
      quantidade: json['quantidade'] as int,
      valor: (json['valor'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$CotationItemToJson(CotationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'quantidade': instance.quantidade,
      'valor': instance.valor,
      'total': instance.total,
    };
