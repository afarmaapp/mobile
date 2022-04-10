import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cpf;

  User({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.cpf,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
