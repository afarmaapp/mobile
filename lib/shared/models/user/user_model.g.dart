// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      cpf: json['cpf'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'telefone': instance.telefone,
      'cpf': instance.cpf,
    };
