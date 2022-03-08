import 'dart:convert';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'Department.dart';

class Medication /* extends Equatable implements Comparable */ {
  static String defaultImage = 'assets/images/defaultMedImage.png';

  Medication({
    required this.id,
    required this.nome,
    required this.ean,
    required this.descricao,
    required this.departamento,
    required this.indicacao,
    required this.contraIndicacao,
    required this.photo,
    this.quantidade,
    required this.precoMedio,
    this.lojaPromocao,
  });

  final String id;
  final String nome;
  final String ean;
  final String descricao;
  final Department? departamento;
  final String indicacao;
  final String contraIndicacao;
  final String photo;
  final int? quantidade;
  final double precoMedio;
  final String? lojaPromocao;

  static List<Medication> fromJSONList(String jsonList) {
    List<Medication> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Medication.fromJSON(json)));
    return ret;
  }

  factory Medication.fromJSON(Map<String, dynamic> json) {
    int index = MedicationRepository()
        .meds
        .indexWhere((element) => element.id == json['id'] as String);
    if (index != -1) {
      return MedicationRepository().meds[index];
    }
    Medication ret = Medication(
      id: (json['id'] ?? '') as String,
      nome: (json['nome'] ?? '') as String,
      ean: (json['ean'] ?? '') as String,
      descricao: (json['descricao'] ?? '') as String,
      // departamento: Department.fromJSON(json['departamento'] ?? {}), // Estava trazendo um departamento NÃO IDENTIFICADO que estava ferrando tudo!
      departamento: null,
      indicacao: (json['indicacao'] ?? '') as String,
      contraIndicacao: (json['contraIndicacao'] ?? '') as String,
      photo: json['photo'] == null ? '' : json['photo']['id'] ?? '',
      precoMedio: (json['precoMedio'] ?? 0.0) as double,
      lojaPromocao: (json['lojaPromocao'] ?? '') as String,
    );
    // Esta linha de baixo fazia add 2 vezes!!!
    // MedicationRepository().addMedication(ret);
    return ret;
  }

  String getPrecoMedioFormated() {
    var valorMaskControlller = MoneyMaskedTextController(
        decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
    valorMaskControlller.updateValue(this.precoMedio);
    return valorMaskControlller.text;
  }

  Widget medImage() {
    return medImageSized(null, 150, BoxFit.cover);
  }

  Widget medImageFit(BoxFit fit) {
    return medImageSized(null, 150, fit);
  }

  Widget medImageSized(double? width, double? height, BoxFit fit) {
    String imgURL404 = 'assets/images/defaultMedImage.png';
    try {
      if (this.photo == '') {
        return Image.asset(imgURL404);
      }

      String url =
          "https://afarma.juliancesar.com:8443/afarma-skp-client/api/v1/ServicosView/imageProduto/${this.photo}";

      return this.photo == '69d460dc-c484-4cf6-b18b-3bd102acfd7a'
          ? Image.asset(
              'assets/images/afarmaGeneric.png', height: height ?? 150,
              width: width ?? null,
              // fit: BoxFit.cover,
              fit: fit,
              alignment: Alignment.center,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(imgURL404);
              },
            )
          : Image.network(
              url,
              height: height ?? 150,
              width: width ?? null,
              // fit: BoxFit.cover,
              fit: fit,
              alignment: Alignment.center,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(imgURL404);
              },
            );
    } catch (e) {
      return Image.asset(imgURL404);
    }
  }

  String toJSON() {
    return '{ "id": "$id" }';
  }

  @override
  bool operator ==(Object other) {
    if (other is Medication) {
      return other.id == id;
    }
    return false;
  }
}
