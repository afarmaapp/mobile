import 'dart:convert';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/repository/DepartmentRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Department extends Equatable implements Comparable {
  Department({this.id, this.name, this.color, this.urlImage});

  final String? id;
  final String? name;
  final Color? color;
  final String? urlImage;
  Image? image;

  static List<Department> fromJSONList(String jsonList) {
    List<Department> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Department.fromJSON(json)));
    return ret;
  }

  factory Department.fromJSON(Map<String, dynamic> json) {
    int index = DepartmentRepository()
        .departments
        .indexWhere((element) => element.id == json['id'] as String?);
    if (index != -1) {
      return DepartmentRepository().departments[index];
    }
    Department ret = Department(
        id: (json['id'] ?? '') as String,
        name: _formattedName(json['departamento'] ?? ''),
        color: _colorFromHex(json['backgroundColor']),
        urlImage: _urlImage(json['id']));
    DepartmentRepository().addDepartment(ret);
    return ret;
  }

  Widget getImage() {
    try {
      return Image.asset(
        this.urlImage!,
        height: 110,
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Text('Erro ao carregar a imagem');
        },
      );
    } catch (e) {
      return Text('Erro ao carregar a imagem');
    }
  }

  static String _urlImage(String? id) {
    // return DefaultURL.apiURL() +
    //     DefaultURI.afarma +
    //     "/api/v1/ServicosView/imageDepartamento/$id";
    String url;

    if (id == 'af591c21-c725-4493-8cba-e4d483589a1e') {
      url = 'assets/images/higiene-bg.jpg';
    } else if (id == 'e732454a-0367-4730-bb48-a92ae40049ec') {
      url = 'assets/images/medicamentos-bg.jpg';
    } else if (id == 'aea8d3be-9a5d-4ee2-bbcc-fc135ea14113') {
      url = 'assets/images/infantil-bg.jpg';
    } else if (id == '6c935ccb-9b76-48f1-afdb-29f1cca325bc') {
      url = 'assets/images/bem-estar-bg.jpg';
    } else if (id == '947f0011-04c6-498c-a0da-e4c1008c9874') {
      url = 'assets/images/dermo-bg.jpg';
    } else {
      url = 'assets/images/beleza-bg.jpg';
    }

    return url;
  }

  static String _formattedName(String str) {
    if (str == "") return "";
    String first = str.substring(0, 1);
    return first + str.substring(1, str.length).toLowerCase();
  }

  static Color _colorFromHex(String? hexString) {
    if (hexString == null) return Colors.red;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  List<Object?> get props => [id, name];

  @override
  int compareTo(other) {
    if (other is Department) {
      return name!.compareTo(other.name!);
    }
    return -1;
  }
}
