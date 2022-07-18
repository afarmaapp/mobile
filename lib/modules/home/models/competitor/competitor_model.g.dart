// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competitor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competitor _$CompetitorFromJson(Map<String, dynamic> json) => Competitor(
      concorrente: json['concorrente'] as String,
      valorConcorrente: (json['valor_concorrente'] as num).toDouble(),
    );

Map<String, dynamic> _$CompetitorToJson(Competitor instance) =>
    <String, dynamic>{
      'concorrente': instance.concorrente,
      'valorConcorrente': instance.valorConcorrente,
    };
