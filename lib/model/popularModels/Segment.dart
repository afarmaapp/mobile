import 'dart:convert';

import 'package:afarma/repository/popularRepositories/SegmentManager.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Segment extends Equatable implements Comparable {
  Segment({this.id, this.description, this.level, this.order, this.color});

  final String? id;
  final String? description;
  final int? level;
  final int? order;
  final Color? color;

  static List<Segment> fromJSONList(String jsonList) {
    List<Segment> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Segment.fromJSON(json)));
    return ret;
  }

  factory Segment.fromJSON(Map<String, dynamic> json) {
    int index = SegmentManager()
        .segments
        .indexWhere((element) => element.id == json['id'] as String?);
    if (index != -1) {
      return SegmentManager().segments[index];
    }
    Segment ret = Segment(
        id: (json['id']) as String,
        description: _formattedName(json['descricao']),
        level: (json['level'] ?? 0) as int,
        order: (json['order'] ?? 0) as int,
        color: _colorFromHex(json['rgb']));
    SegmentManager().addSegment(ret);
    return ret;
  }

  static String _formattedName(String str) {
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
  List<Object?> get props => [id, description];

  @override
  int compareTo(other) {
    if (other is Segment) {
      return order!.compareTo(other.order!);
    }
    return -1;
  }
}
