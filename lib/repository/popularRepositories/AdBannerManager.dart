import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/AdBanner.dart';
import 'package:flutter/foundation.dart';

class AdBannerManager extends ChangeNotifier {
  static final AdBannerManager _manager = AdBannerManager._initializer();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory AdBannerManager() {
    return _manager;
  }

  AdBannerManager._initializer();

  List<AdBanner> _ads = [];
  List<AdBanner> get ads => _ads;

  Future<List<AdBanner>> getAds() async {
    final resp = await _connector.getContent('/api/v1/Banner/list');
    if (resp.responseCode! < 400) {
      _ads = AdBanner.fromJSONList(resp.returnBody!);
      notifyListeners();
    }
    return _ads;
  }
}
