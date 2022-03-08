import 'dart:io';
import 'package:afarma/helper/popularHelpers/Connector.dart';

import 'NotificationDB.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FirebaseNotifications {
  late FirebaseMessaging _firebaseMessaging;

  //final void Function(String) callback;

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging.instance;
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) iOSPermission();
    print('Ios firebaseCloudMessagingListeners');
    _firebaseMessaging.getToken().then((token) {
      Connector.setDeviceToken(token!);
      print("token: $token");
    });
  }

  void handleMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message);
      AlertDialog(
        title: Text('Nova mensagem'),
        content: Text(message.toString()),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {},
          ),
        ],
      );
      // insertMessage(message);
    });
    // FirebaseMessaging.onResume:
    // (RemoteMessage message) async {
    //   print('on resume $message');
    // };
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('on message opened $message');
    });
  }

  insertMessage(message) async {
    final dbHelper = NotificationDB.instance;

    Map<String, dynamic> row = {
      NotificationDB.columnTitle: message['notification']['title'],
      NotificationDB.columnContent: message['notification']['body'],
      NotificationDB.columnClassId: message['data']['aulaId'],
      NotificationDB.columnNotificationType: message['data']['tipo'],
    };

    dbHelper.insert(row);
  }

  void iOSPermission() async {
    print('Ios permission');
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _firebaseMessaging.requestPermission();
  }
}
