import 'dart:convert';

import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'SignUpController.dart';
//import 'HomeController.dart';

class LoginInput {
  static const List<String> _modifiers = ['+dev', '+hom'];

  LoginInput({this.login, this.password, this.deviceToken});

  String? login = '';
  String? password = '';
  String? deviceToken = '';
  bool loginLock = false;

  String loginModifier() {
    if (login != null) {
      return _modifiers.firstWhere((modifier) => login!.contains(modifier),
          orElse: () => '+prod');
    }
    return '';
  }

  String? filteredLogin() {
    if (login != null) {
      for (String modifier in _modifiers) {
        if (login!.contains(modifier)) return login!.replaceAll(modifier, '');
      }
      return login;
    }
    return '';
  }

  bool canLogin() {
    return (login != null && login != '' && password != null && password != '');
  }

  void clear() {
    login = '';
    password = '';
  }
}

class AppColors {
  static Color mainColor = Color.fromRGBO(244, 14, 138, 1);
}

class LoginController extends StatefulWidget {
  LoginController({this.isFromPurchase = false});

  final bool isFromPurchase;

  @override
  _LoginControllerState createState() => _LoginControllerState();
}

class _LoginControllerState extends State<LoginController> {
  final LoginInput userInput = LoginInput();
  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  bool isDarkMode() {
    return (MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void performPasswordReset(BuildContext context) {
    showDialog(
        builder: (context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              )
            ],
            content: TextField(
              onSubmitted: (text) {
                Navigator.pop(context);
                _connector.postContentWithParams(
                    '/autenticacao/senha/esquecer', {'email': text}, '');
                showDialog(
                    builder: (context) {
                      return AlertDialog(
                        actions: <Widget>[
                          FlatButton(
                              child: Text('ok'),
                              onPressed: () => Navigator.pop(context)),
                        ],
                        title: Text(
                            'Enviamos para você um email para resetar sua senha.'),
                      );
                    },
                    context: context);
              },
            ),
            title: Text('Insira seu email:'),
          );
        },
        context: context);
  }

  void _displayAlert(String title, String msg, BuildContext context) {
    final dialog = AlertDialog(
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
      content: Text(msg),
      title: Text(title),
    );
    showDialog(
        builder: (context) {
          return dialog;
        },
        context: context);
  }

  // factory _LoginControllerState.fromJSON(Map<String, dynamic> json) {
  //   return _LoginControllerState(
  //     error: json['error'] as String,
  //   );
  // }

  void handleLoginError(Return ret, BuildContext context) {
    print(ret);
    if (ret.responseCode == 200 || ret.responseCode == 201) {
      return;
    } else {
      List<dynamic> bodyError = jsonDecode(ret.returnBody!);

      print(bodyError[0]['error']);
      _displayAlert('Erro', bodyError[0]['error'], context);
    }
  }

  void _performLogin() async {
    if (userInput.canLogin()) {
      userInput.deviceToken = await Connector.getDeviceToken();

      print(userInput.deviceToken);
      final login = await _connector.loginWithParams(userInput);
      await User.fetch();
      handleLoginError(login, context);
      if (login.responseCode == 200 || login.responseCode == 201) {
        if (userInput.loginLock == true) {
          return;
        }
        userInput.loginLock = true;
        if (widget.isFromPurchase) {
          Navigator.popUntil(context, ModalRoute.withName('PurchaseRoute'));
        } else {
          Navigator.popUntil(context, ModalRoute.withName('RegisterRoute'));
          Navigator.pop(context);
        }
        setState(() {
          userInput.clear();
        });
      }
    } else {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
              content: Text('Preencha os campos acima e tente novamente'),
              title: Text('Erro'),
            );
          },
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _mainBody(context),
      padding: EdgeInsets.only(
          //bottom: 20.0,
          //left: 20.0,
          //right: 20.0
          ),
    );
  }

  Widget _mainBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //_quitIconButton(),
          //_lognText(),
          _inputTextFields(),
          _loginButton()
        ],
      ),
    );
  }

  Widget _quitIconButton() {
    return Align(
      alignment: Alignment.topCenter,
      child: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Color.fromRGBO(0, 169, 211, 1), /* light-ish blue */
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _lognText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Faça login',
        style: TextStyle(
            color: Color.fromRGBO(255, 49, 49, 1),
            /* red */
            fontSize: 22,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _inputTextFields() {
    double heightSeparation = 12.0;
    return Column(
      children: [
        SizedBox(height: heightSeparation),
        _textField('Email', false, (val) {
          userInput.login = val;
        }),
        SizedBox(height: heightSeparation),
        _textField('Senha', true, (val) {
          userInput.password = val;
        }),
        SizedBox(height: heightSeparation),
      ],
    );
  }

  Widget _textField(String hintText, bool hides, Function(String val) fun) {
    OutlineInputBorder border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none);
    return TextField(
      autocorrect: false,
      autofocus: false,
      decoration: InputDecoration(
          border: border,
          focusedBorder: border,
          filled: true,
          fillColor: Color.fromRGBO(206, 206, 206, 0.3),
          /* light grey */
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey)),
      enableSuggestions: false,
      expands: false,
      maxLines: 1,
      obscureText: hides,
      onChanged: fun,
      onSubmitted: fun,
      style: TextStyle(color: Colors.black),
      textCapitalization: TextCapitalization.none,
      textAlign: TextAlign.left,
    );
  }

  Widget _loginButton() {
    return Padding(
      child: ButtonTheme(
        child: RaisedButton(
          child: Text(
            'Entrar',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          color: Color.fromRGBO(255, 49, 49, 1),
          /* red */
          onPressed: () => _performLogin(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minWidth: MediaQuery.of(context).size.width - 80,
        height: 45,
      ),
      padding: EdgeInsets.only(bottom: 12.0),
    );
  }
}
