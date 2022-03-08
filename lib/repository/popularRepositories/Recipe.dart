import 'dart:convert';

import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  Recipe({this.id, this.crm, this.description, this.dataEmissaoReceita});

  String? id;
  String? crm;
  String? description;
  String? dataEmissaoReceita;

  static List<Recipe> fromJSONList(String json) {
    if (json == null) return [];
    List parsed = jsonDecode(json);
    List<Recipe> ret = [];
    parsed.forEach((recipe) => ret.add(Recipe.fromJSON(recipe)));
    ret.removeWhere((element) => element == null);
    return ret;
  }

  factory Recipe.fromJSON(List<dynamic> recipes) {
    Map<String, dynamic> json = recipes[0];
    if (json == null) return Recipe();
    return Recipe(
      id: (json['id'] ?? '') as String,
      crm: (json['crm'] ?? '') as String,
      description: (json['descricao'] ?? '') as String,
      dataEmissaoReceita: (json['dataEmissaoReceita'] ?? '') as String,
    );
  }

  String toJSON() {
    return '{ "id": "$id", "crm": "$crm", "descricao": "$description", "dataEmissaoReceita": "$dataEmissaoReceita" }';
  }

  bool canBeAdded() {
    return id != null &&
        id!.trim() != '' &&
        crm != null &&
        crm!.trim() != '' &&
        description != null &&
        description!.trim() != '' &&
        dataEmissaoReceita != null &&
        dataEmissaoReceita!.trim() != '';
    //RECADO ELIZIER: Verificar se lat e lng são diferentes de 0.0
  }

  @override
  List<Object?> get props => [id];
}
