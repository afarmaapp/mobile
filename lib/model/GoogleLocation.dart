import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Address.dart';

class GoogleLocation {
  GoogleLocation(
      {this.street,
      this.number,
      this.neighborhood,
      this.city,
      this.state,
      this.postalCode,
      this.location,
      this.placeID,
      this.country});

  final GoogleLocationComponent? street;
  final GoogleLocationComponent? number;
  final GoogleLocationComponent? neighborhood;
  final GoogleLocationComponent? city;
  final GoogleLocationComponent? state;
  final GoogleLocationComponent? postalCode;
  final GoogleLocationComponent? country;

  final LatLng? location;
  final String? placeID;

  factory GoogleLocation.fromJSON(Map<String, dynamic> json) {
    List componentsJson = json['address_components'];
    List<GoogleLocationComponent> components =
        GoogleLocationComponent.fromJSONList(componentsJson);
    return GoogleLocation(
        street: components.firstWhere((element) => element.types!.contains('route'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        number: components.firstWhere((element) => element.types!.contains('street_number'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        neighborhood: components.firstWhere(
            (element) => element.types!.contains('sublocality'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        city: components.firstWhere(
            (element) => element.types!.contains('administrative_area_level_2'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        state: components.firstWhere(
            (element) => element.types!.contains('administrative_area_level_1'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        postalCode: components.firstWhere(
            (element) => element.types!.contains('postal_code'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        country: components.firstWhere((element) => element.types!.contains('country'),
            orElse: () => GoogleLocationComponent._defaultComponent),
        location: _locationFromJSON(json),
        placeID: json['place_id'] ?? '');
  }

  static LatLng _locationFromJSON(Map<String, dynamic> json) {
    Map? location = json['geometry']['location'];
    return location != null
        ? LatLng(location['lat'], location['lng'])
        : LatLng(0.000, 0.000);
  }

  bool isBrazil() {
    return (country ?? GoogleLocationComponent._defaultComponent).shortName ==
        'BR';
  }

  Address toAddress() {
    return Address(
      description: 'Minha localiza????o',
      id: placeID ?? '',
      street: street!.longName ?? '',
      number: number!.longName ?? '',
      neighborhood: neighborhood!.longName ?? '',
      city: city!.longName ?? '',
      cep: postalCode!.longName ?? '',
      state: state!.shortName ?? '',
      position: location ?? LatLng(0.000, 0.000),
      googleAddress: this,
      located: true,
    );
  }

  static GoogleLocation errorLocation = GoogleLocation(
      street: GoogleLocationComponent._errorComponent,
      number: GoogleLocationComponent._errorComponent,
      neighborhood: GoogleLocationComponent._errorComponent,
      city: GoogleLocationComponent._errorComponent,
      state: GoogleLocationComponent._errorComponent,
      postalCode: GoogleLocationComponent._errorComponent,
      country: GoogleLocationComponent._errorComponent,
      location: LatLng(-1000, 1000),
      placeID: 'noPlaceID');
}

class GoogleLocationComponent {
  GoogleLocationComponent({this.longName, this.shortName, this.types});

  final String? longName;
  final String? shortName;
  final List<String>? types;

  static List<GoogleLocationComponent> fromJSONList(List json) {
    List<GoogleLocationComponent> ret = [];
    json.forEach(
        (element) => ret.add(GoogleLocationComponent.fromJSON(element)));
    return ret;
  }

  factory GoogleLocationComponent.fromJSON(Map<String, dynamic> json) {
    return GoogleLocationComponent(
        longName: json['long_name'],
        shortName: json['short_name'],
        types: (json['types'] as List).map((e) => e.toString()).toList());
  }

  bool isValid() => longName != null && longName!.trim() != '';

  static GoogleLocationComponent _defaultComponent =
      GoogleLocationComponent(longName: '', shortName: '', types: []);
  static GoogleLocationComponent _errorComponent = GoogleLocationComponent(
      longName: 'error', shortName: 'err', types: ['error', 'err']);
}
