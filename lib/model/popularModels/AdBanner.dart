import 'dart:convert';

class AdBanner {

  AdBanner({
    this.id,
    this.imgURL,
    this.redirectURL
  });

  final String? id;
  final String? imgURL;
  final String? redirectURL;

  static List<AdBanner> fromJSONList(String jsonList) {
    List<AdBanner> ret = [];
    List parsedResp = jsonDecode(jsonList);
    parsedResp.forEach((ad) => ret.add(AdBanner.fromJSON(ad)));
    return ret;
  }

  factory AdBanner.fromJSON(Map<String, dynamic> json) {
    return AdBanner(
      id: (json['id'] ?? '') as String,
      imgURL: (json['image'] ?? '') as String,
      redirectURL: (json['url'] ?? '') as String
    );
  }

}