import 'dart:io';

import 'package:afarma/helper/popularHelpers/CurrentDeviceInfo.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';

class TestWidget extends StatefulWidget {
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  FocusNode focus = FocusNode();
  KeyboardUtils _keyboardUtils = KeyboardUtils();
  double bottomPadding = 0.0;

  bool? shouldFix;

  @override
  void initState() {
    super.initState();
    shouldFixFlutter();
    _keyboardUtils.add(
        listener: KeyboardListener(
            willHideKeyboard: handleHideKeyboard,
            willShowKeyboard: (kHeight) => handleShowKeyboard(kHeight)));
  }

  bool? shouldFixFlutter() {
    // basicamente fazemos o trabalho que o flutter devia fazer,
    // "levantar" a tela caso o textField não esteja visível nos
    // OSes que possuem o erro, mantendo o comportamento padrão nos
    // que não possuem.
    if (Platform.isAndroid) {
      Object? info = CurrentDeviceInfo().deviceInfo;
      if (info != null) {
        if (info is AndroidDeviceInfo) {
          // por enquanto, esse erro no teclado só ocorre em androids
          // com sdk < 30
          shouldFix = (info.version.sdkInt < 30);
        } else {
          print('what?');
        }
      } else {
        CurrentDeviceInfo()
            .getCurrentDeviceInfo()
            .then((_) => shouldFixFlutter());
      }
    } else {
      shouldFix = false;
    }
    return shouldFix;
  }

  void handleHideKeyboard() {
    bottomPadding = 0.0;
    if (shouldFix! && mounted) setState(() {});
  }

  void handleShowKeyboard(double kHeight) {
    if (shouldFix!) {
      bottomPadding = kHeight;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: Text(
          'Teste',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: mainBuild(),
        padding: EdgeInsets.only(bottom: bottomPadding),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget mainBuild() {
    return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 150,
              ),
              TextFormField(
                focusNode: focus,
                decoration: InputDecoration(
                    focusColor: Colors.red, fillColor: Colors.blue),
                onChanged: (val) {
                  printData();
                },
                onFieldSubmitted: (val) {
                  printData();
                },
              )
            ],
          ),
        ));
  }

  void printData() {
    EdgeInsets data = MediaQuery.of(context).padding;
    print('top: ${data.top}, bottom: ${data.bottom}');
  }

  @override
  void dispose() {
    super.dispose();
    _keyboardUtils.removeAllKeyboardListeners();
    _keyboardUtils.dispose();
  }
}
