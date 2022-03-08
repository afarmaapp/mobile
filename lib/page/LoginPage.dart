import 'dart:ui';

import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Login.dart';
import 'package:afarma/model/Return.dart';
import 'package:afarma/service/LoggedInNotifierService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.isFromPurchase = false, this.isFromPromocoes = false});

  final bool isFromPurchase;
  final bool isFromPromocoes;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Login userInput = Login();

  FocusNode focusSelector = FocusNode();

  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  bool isDarkMode() {
    return (MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _loadingAlert(String title) {
    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              content: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary /* red */),
                  ),
                  SizedBox(height: 20.0),
                  Text(title)
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          );
        },
        context: context);
  }

  void _displayAlert(String title, String msg, BuildContext context) {
    final dialog = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
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
      ),
    );
    showDialog(
        builder: (context) {
          return dialog;
        },
        context: context);
  }

  void handleLoginError(Return ret, BuildContext context) {
    if (ret.responseCode == 200 || ret.responseCode == 201) {
      return;
    }
    Navigator.pop(context);
    _displayAlert('Erro', 'Não foi possível realizar o login', context);
  }

  void _performLogin() async {
    if (userInput.canLogin()) {
      _loadingAlert('Autenticando...');
      try {
        final login = await _connector.loginWithParams(userInput);
        handleLoginError(login, context);
        if (login.responseCode == 200 || login.responseCode == 201) {
          if (userInput.loginLock == true) {
            return;
          }
          userInput.loginLock = true;

          // Avisa todos que logou!
          LoggedInNotifierService().setLogged(true);

          if (widget.isFromPurchase) {
            Navigator.popUntil(
                context, ModalRoute.withName('ComparativeRoute'));
          } else if (widget.isFromPromocoes) {
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          } else {
            // Vai para a home
            Navigator.of(
              context,
            ).popUntil((route) {
              return route.isFirst;
            });
          }
          setState(() {
            userInput.clear();
          });
        }
      } catch (Exception) {
        Navigator.pop(context);
        showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                content: Text('Ocorreu um erro, tente novamente'),
                title: Text('Erro'),
              ),
            );
          },
          context: context,
        );
      }
    } else {
      showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                content: Text('Preencha os campos acima e tente novamente'),
                title: Text('Erro'),
              ),
            );
          },
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _mainBody(context));
  }

  Widget _mainBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _inputTextFields(),
          _loginButton(),
        ],
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
        }, TextInputType.emailAddress),
        SizedBox(height: heightSeparation),
        _textField('Senha', true, (val) {
          userInput.password = val;
        }, TextInputType.text),
        SizedBox(height: heightSeparation),
      ],
    );
  }

  Widget _textField(String hintText, bool hides, Function(String val) fun,
      TextInputType textInputType) {
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
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey)),
      enableSuggestions: false,
      expands: false,
      maxLines: 1,
      obscureText: hides,
      keyboardType: textInputType,
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
          color: AppColors.primary,
          onPressed: () {
            // Tira o foco do campo para não voltar a ter teclado!
            FocusScope.of(context).unfocus();
            // Realiza o login
            _performLogin();
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minWidth: MediaQuery.of(context).size.width - 80,
        height: 45,
      ),
      padding: EdgeInsets.only(bottom: 12.0),
    );
  }
}
