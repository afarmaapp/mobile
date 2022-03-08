import 'dart:convert';
import 'package:afarma/repository/BannerRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Banner extends Equatable {
  Banner({this.id, this.text, this.urlImage});

  final String? id;
  final String? text;
  final String? urlImage;
  Image? image;

  static List<Banner> fromJSONList(String jsonList) {
    List<Banner> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Banner.fromJSON(json)));
    return ret;
  }

  factory Banner.fromJSON(Map<String, dynamic> json) {
    int index = BannerRepository()
        .banners
        .indexWhere((element) => element.id == json['id'] as String?);
    if (index != -1) {
      return BannerRepository().banners[index];
    }
    Banner ret = Banner(
        id: (json['id'] ?? '') as String,
        text: (json['image'] ?? ''),
        urlImage: json['url']);
    BannerRepository().addBanner(ret);
    return ret;
  }

  Image? getImage() {
    try {
      return Image.network(
        this.urlImage!,
        fit: BoxFit.cover,
        width: 1000.0,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Text('Your error widget...');
        },
      );
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [id, text];
}
