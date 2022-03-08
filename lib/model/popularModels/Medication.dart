import 'dart:convert';

import 'package:afarma/model/popularModels/Segment.dart';
import 'package:afarma/repository/popularRepositories/MedicationManager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class Medication extends Equatable implements Comparable {
  static String defaultImage = 'assets/images/defaultMedImage.png';

  Medication(
      {this.id,
      this.name,
      this.amount,
      this.description,
      this.tags,
      this.segment,
      this.posology,
      this.allowedAmount,
      this.price,
      this.restricted});

  final String? id;
  final String? name;
  final String? amount;
  final String? description;
  final List<String>? tags;
  final Segment? segment;
  final String? posology;
  final int? allowedAmount;
  final double? price;
  final bool? restricted;

  static List<Medication> fromJSONList(String jsonList) {
    List<Medication> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Medication.fromJSON(json)));
    return ret;
  }

  factory Medication.fromJSON(Map<String, dynamic>? json) {
    int index = MedicationManager()
        .meds
        .indexWhere((element) => element.id == json!['id'] as String?);
    if (index != -1) {
      return MedicationManager().meds[index];
    }
    Medication ret = Medication(
        id: (json!['id'] ?? '') as String,
        name: (json['nome'] ?? '') as String,
        amount: (json['conteudoEmbalagem'] ?? '') as String,
        description: (json['descricao'] ?? '') as String,
        tags: [],
        segment:
            Segment.fromJSON(json['segmento'] ?? {} as Map<String, dynamic>),
        posology: (json['posologia'] ?? '') as String,
        allowedAmount: (json['quantidadeObrigatoria'] ?? 1) as int,
        price: _priceFromJSON(json),
        restricted: (json['restrito'] ?? false) as bool);
    MedicationManager().addMedication(ret);
    return ret;
  }

  ImageProvider medImage() {
    String imgURL = 'assets/images/';
    if (segment != null &&
        segment!.description!.toLowerCase().contains('fralda')) {
      imgURL += 'diaperImage.jpg';
    } else {
      imgURL += 'defaultMedImage.png';
    }
    return AssetImage(imgURL);
  }

  String toJSON() {
    return '{ "id": "$id" }';
  }

  static double _priceFromJSON(Map<String, dynamic> json) {
    if (json.containsKey('valor')) {
      double val = json['valor'] ?? -1.0;
      return val == 0.0 ? -1.0 : val;
    }
    return -1.0;
  }

  @override
  List<Object?> get props => [name, amount, description];

  bool needsPayment() => price != -1.0;

  @override
  bool operator ==(Object other) {
    if (other is Medication) {
      return other.id == id;
    }
    return false;
  }

  @override
  int compareTo(other) {
    if (other is Medication) {
      if (segment!.order! < other.segment!.order!) {
        return -1;
      } else if (segment!.order == other.segment!.order) {
        return name!.toLowerCase().compareTo(other.name!.toLowerCase());
      } else {
        return 1;
      }
    }
    return -1;
  }
}
