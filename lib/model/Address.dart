import 'dart:convert';
import 'package:afarma/model/GoogleLocation.dart';
import 'package:afarma/repository/AddressRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address extends Equatable {
  Address({
    this.id,
    this.description,
    this.type,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.cep,
    this.state,
    this.position,
    this.googleAddress,
    required this.located,
  });

  String? id;
  String? description;
  String? type;
  String? street;
  String? number;
  String? complement;
  String? neighborhood;
  String? city;
  String? cep;
  String? state;
  LatLng? position;
  bool located = false;

  GoogleLocation? googleAddress;

  static List<Address> fromJSONList(String? json) {
    if (json == null) return [];
    List parsed = jsonDecode(json);
    List<Address> ret = [];
    parsed.forEach((address) {
      if (address != null) {
        ret.add(Address.fromJSON(address));
      }
    });
    return ret;
  }

  factory Address.fromJSON(Map<String, dynamic> json) {
    int index = AddressRepository()
        .addresses
        .indexWhere((address) => address.id == json['id']);
    if (index != -1) {
      return AddressRepository().addresses[index];
    }
    return Address(
        id: (json['id'] ?? '') as String,
        description: (json['descricao'] ?? '') as String,
        type: (json['tipo'] ?? '') as String,
        street: (json['logradouro'] ?? '') as String,
        number: (json['numero'] ?? '') as String,
        complement: (json['complemento'] == "null"
            ? ''
            : json['complemento'] ?? '') as String,
        neighborhood: (json['bairro'] ?? '') as String,
        city: (json['cidade'] ?? '') as String,
        cep: (json['cep'] ?? '') as String,
        state: (json['uf'] ?? '') as String,
        position: _getPosition(json),
        located: true);
  }

  static LatLng _getPosition(Map<String, dynamic> json) {
    double lat;
    double lng;
    if (json['lat'] is int) {
      lat = double.tryParse('${json['lat']}') ?? 0.0;
      lng = double.tryParse('${json['lng']}') ?? 0.0;
    } else {
      lat = json['lat'] ?? 0.0;
      lng = json['lng'] ?? 0.0;
    }
    return LatLng(lat, lng);
  }

  String toJSON() {
    String pos = position != null
        ? ', "lat": ${position!.latitude.toStringAsFixed(6)}, "lng": ${position!.longitude.toStringAsFixed(6)} '
        : '';
    return '{ "descricao": "$description", "logradouro": "$street", "numero": "$number", "complemento": "$complement", "bairro": "$neighborhood", "cidade": "$city", "cep": "$cep", "uf": "$state"$pos }';
  }

  String toWatermark() {
    return '$street - $number \n$complement \n$neighborhood - $cep \n $city/$state';
  }

  bool canBeAdded() {
    return description != null &&
        description!.trim() != '' &&
        street != null &&
        street!.trim() != '' &&
        number != null &&
        number!.trim() != '' &&
        // complement != null &&
        // complement.trim() != '' &&
        neighborhood != null &&
        neighborhood!.trim() != '' &&
        city != null &&
        city!.trim() != '' &&
        cep != null &&
        cep!.trim() != '' &&
        state != null &&
        state!.trim() != '';
  }

  @override
  List<Object?> get props => [id, street, number];
}
