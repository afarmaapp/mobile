// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competitors_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competitors _$CompetitorsFromJson(Map<String, dynamic> json) => Competitors(
      concorrente: json['concorrente'] as String,
      valorConcorrente: (json['valor_concorrente'] as num).toDouble(),
    );

Map<String, dynamic> _$CompetitorsToJson(Competitors instance) =>
    <String, dynamic>{
      'concorrente': instance.concorrente,
      'valorConcorrente': instance.valorConcorrente,
    };
