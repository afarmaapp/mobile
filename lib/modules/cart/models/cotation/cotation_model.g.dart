// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cotation _$CotationFromJson(Map<String, dynamic> json) => Cotation(
      id: json['id'] as String,
      itens: (json['itens'] as List<dynamic>)
          .map((e) => CotationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      loja: json['loja'] as String,
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$CotationToJson(Cotation instance) => <String, dynamic>{
      'id': instance.id,
      'itens': instance.itens,
      'loja': instance.loja,
      'total': instance.total,
    };
