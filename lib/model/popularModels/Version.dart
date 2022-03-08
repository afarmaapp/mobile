import 'dart:convert';

import 'package:afarma/repository/popularRepositories/VersionManager.dart';
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
    int index = VersionManager()
        .versions
        .indexWhere((element) => element.id == json['id'] as int?);
    if (index != -1) {
      return VersionManager().versions[index];
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

  // @override
  // int compareTo(other) {
  //   if (other is Version) {
  //     return id.compareTo(other.id);
  //   }
  //   return -1;
  // }
}
