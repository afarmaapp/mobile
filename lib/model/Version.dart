import 'dart:convert';
import 'package:afarma/repository/VersionRepository.dart';
import 'package:equatable/equatable.dart';

class Version extends Equatable {
  Version({this.id, this.vAPP, this.active});

  final int? id;
  final String? vAPP;
  final bool? active;

  static List<Version> fromJSONList(String jsonList) {
    List<Version> ret = [];
    jsonDecode(jsonList).forEach((json) => ret.add(Version.fromJSON(json)));
    return ret;
  }

  factory Version.fromJSON(Map<String, dynamic> json) {
    int index = VersionRepository()
        .versions
        .indexWhere((element) => element.id == json['id'] as int?);

    if (index != -1) {
      return VersionRepository().versions.elementAt(index);
    }

    Version ret = Version(
      id: (json['id'] ?? 0) as int,
      vAPP: (json['vAPP'] ?? '') as String,
      active: (json['active'] ?? null) as bool?,
    );
    return ret;
  }

  @override
  List<Object?> get props => [id, vAPP];
}
