import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Banner.dart';
import 'package:flutter/foundation.dart';

class BannerRepository extends ChangeNotifier {
  static final BannerRepository _manager = BannerRepository._initializer();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  factory BannerRepository() {
    return _manager;
  }

  BannerRepository._initializer();

  List<Banner> _banners = [];
  List<Banner> get banners => _banners;

  void addBanner(Banner banner) {
    if (_banners == null || _banners.length == 0) {
      _banners = [banner];
    } else {
      if (!_banners.contains(banner)) _banners.add(banner);
    }
  }

  Future<List<Banner>> fetchBanners() async {
    if (_banners == null || _banners.length == 0) return await refreshBanners();
    return _banners;
  }

  Future<List<Banner>> refreshBanners() async {
    _banners = [];
    final resp = await _connector.getContent('/api/v1/Banner/list');
    Banner.fromJSONList(resp.returnBody!);
    return _banners;
  }
}
