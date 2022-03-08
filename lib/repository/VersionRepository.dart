import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Version.dart';
import 'package:flutter/foundation.dart';

class VersionRepository extends ChangeNotifier {
  static final VersionRepository _manager = VersionRepository._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory VersionRepository() {
    return _manager;
  }

  VersionRepository._initializer();

  List<Version> _versions = [];
  List<Version> get versions => _versions;

  void addVersion(Version version) {
    if (_versions == null || _versions.length == 0) {
      _versions = [version];
    } else {
      if (!_versions.contains(version)) _versions.add(version);
    }
  }

  Future<List<Version>> fetchVersions() async {
    if (_versions == null || _versions.length == 0)
      return await refreshVersions();
    return _versions;
  }

  Future<List<Version>> refreshVersions() async {
    final resp = await _connector.getContent('/api/v1/Versao/list');
    _versions = Version.fromJSONList(resp.returnBody!);
    return _versions;
  }
}
