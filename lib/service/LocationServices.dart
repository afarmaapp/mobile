import 'dart:convert';

import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/GoogleLocation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

String? googleAPIKey;

class LocationServices {
  static Future<LocationData?> currentLocationCoords() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _locationData = await location.getLocation();
    return _locationData;
  }

  static Future<String?> getAPIKey() async {
    if (googleAPIKey != null) return googleAPIKey;
    Connector connector =
        Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
    final resp = await connector.getContent('/api/v1/autenticacao/gToken');
    if (resp.responseCode! < 400) {
      Map parsed = jsonDecode(resp.returnBody!);
      if (parsed.containsKey('token') && parsed['token'] != null) {
        googleAPIKey = parsed['token'];
        return googleAPIKey;
      }
    } else {
      return googleAPIKey ??= 'noToken';
    }
  }

  static Future<GoogleLocation?> currentLocation() async {
    Dio dio = Dio();

    LocationData? currentLocation = await currentLocationCoords();

    if (currentLocation == null) {
      return null;
    }

    String? token = await getAPIKey();
    if (token == 'noToken') {
      return GoogleLocation.errorLocation;
    }

    dio.options.connectTimeout = DefaultURL.defaultTimeout();
    dio.options.receiveTimeout = DefaultURL.defaultTimeout();

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLocation.latitude},${currentLocation.longitude}&key=$token';

    var response = await dio.request(url);

    Map parsedResp = response.data;

    if (parsedResp['status'] == 'REQUEST_DENIED' && !kReleaseMode) {
      if (!kReleaseMode) {
        Get.dialog(AlertDialog(
          actions: [
            FlatButton(
                child: Text('OK'), onPressed: () => Navigator.pop(Get.context!))
          ],
          content: Text('location error: \n' + parsedResp['error_message']),
        ));
      }
      return GoogleLocation.errorLocation;
    }
    GoogleLocation loc =
        GoogleLocation.fromJSON((parsedResp['results'] as List).first);
    return loc;
  }
}
