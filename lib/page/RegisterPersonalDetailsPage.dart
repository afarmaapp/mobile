import 'dart:convert';
import 'dart:ui';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Login.dart';
import 'package:afarma/model/PersonDetails.dart';
import 'package:afarma/service/LoggedInNotifierService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/gestures.dart';

import 'PolicyPage.dart';

class PersonalDetailsPage extends StatefulWidget {
  PersonalDetailsPage(
      {this.isFromPurchase = false, this.isFromPromocoes = false});

  final bool isFromPurchase;
  final bool isFromPromocoes;

  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  PersonalDetails _personalDetails = PersonalDetails();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: Text(
            'Dados Pessoais',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          child: _mainBody(),
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            child: Column(
              children: [
                SizedBox(height: 20.0),
                _textField('Nome Completo', [], TextInputType.name, (val) {
                  _personalDetails.name = val;
                }, null),
                _textField('CPF', [_cpfFormatter], TextInputType.number, (val) {
                  _personalDetails.cpf = _cpfFormatter.getUnmaskedText();
                }, null),
                _textField('Celular', [_phoneFormatter], TextInputType.number,
                    (val) {
                  _personalDetails.phone = _phoneFormatter.getUnmaskedText();
                },
                    Text(
                      'Insira um número com DDD e 9 dígitos',
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    )),
                _textField('Email', [], TextInputType.emailAddress, (val) {
                  _personalDetails.email = val;
                }, null),
                _textField('Senha', [], TextInputType.text, (val) {
                  _personalDetails.password = val;
                }, null),
                _termsWidget()
              ],
            ),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
          ),
          SizedBox(height: 20.0),
          ButtonTheme(
            child: RaisedButton(
              child: Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              color: AppColors.secondary,
              /* blue */
              onPressed: () {
                // Tira o foco do campo para não voltar a ter teclado!
                FocusScope.of(context).unfocus();
                // Salva
                _saveAndQuit();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            height: 50,
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _termsWidget() {
    return Row(
      children: [
        Checkbox(
          onChanged: (val) {
            _personalDetails.acceptedTerms = val;
            setState(() {});
          },
          value: _personalDetails.acceptedTerms,
        ),
        RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black),
              text: 'Eu li e aceito os ',
              children: [
                TextSpan(
                  style: TextStyle(color: Colors.red),
                  text: 'termos de uso.',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showTerms(),
                )
              ]),
        )
      ],
    );
  }

  Widget _textField(
      String title,
      List<TextInputFormatter> formatters,
      TextInputType keyboardType,
      Function(String) onSubmitted,
      Widget? bottom) {
    final ret = TextField(
      autocorrect: false,
      autofocus: false,
      cursorColor: AppColors.primary,
      /* red */
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(51, 146, 216, 1),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary /* red */)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.6))),
        hintText: title,
        hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
      inputFormatters: formatters,
      enableSuggestions: false,
      expands: false,
      keyboardType: keyboardType,
      maxLines: 1,
      obscureText: (title.toLowerCase() == 'senha'),
      onChanged: onSubmitted,
      onSubmitted: onSubmitted,
      textCapitalization: TextCapitalization.none,
      style: TextStyle(color: Colors.black),
    );
    return Padding(
      child: Column(
        children: [ret, (bottom != null) ? bottom : Container()],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  void _saveAndQuit() async {
    if (!_personalDetails.acceptedTerms!) {
      return _alert('Aceite os termos de uso e tente novamente.', null);
    }

    if (_personalDetails.canConfirm()) {
      return _sendUserDetails();
    } else {
      showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                content: Text('Preencha todos os campos e tente novamente'),
              ),
            );
          },
          context: context);
    }
  }

  void _sendUserDetails() async {
    _loadingAlert('Criando usuário...');
    final resp = await _connector.postContentWithBody(
        '/api/v1/Usuario/persist', await _personalDetails.toJSONWithToken());
    print('DeviceToken: ${_personalDetails.toJSONWithToken()}');
    Navigator.pop(context);
    if (resp.responseCode! < 400) {
      Map parsedResp = jsonDecode(resp.returnBody!);
      String? passwordToken = parsedResp['codigoCadastroSenha'] as String?;
      return _registerPassword(passwordToken);
    } else if (resp.responseCode == 409) {
      return _alert('Usuário já cadastrado.', null);
    } else {
      return _alert(
          'Ocorreu um erro ao criar o usuário, tente novamente mais tarde.',
          resp.responseCode);
    }
  }

  void _registerPassword(String? token) async {
    _loadingAlert('Cadastrando senha...');
    final resp = await _connector.postContentWithBody(
        '/api/v1/autenticacao/senha/criar',
        '{ "email": "${_personalDetails.email!.trim()}", "novaSenha": "${_personalDetails.password!.trim()}", "codigoCadastroSenha": "$token" }');
    Navigator.pop(context);
    if (resp.responseCode! < 400) {
      _loadingAlert('Autenticando...');

      final login = await _connector.loginWithParams(Login(
          login: _personalDetails.email, password: _personalDetails.password));
      Navigator.pop(context);
      if (login.responseCode! < 400) {
        // Avisa todos que logou!
        LoggedInNotifierService().setLogged(true);

        showDialog(
            builder: (context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  actions: [
                    FlatButton(
                      child: Text('Continuar'),
                      onPressed: () {
                        if (widget.isFromPurchase) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else if (widget.isFromPromocoes) {
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                        } else {
                          Navigator.pop(context); // alerta
                          Navigator.pop(context); // essa tela
                          Navigator.pop(context); // tela de autenticação
                          Navigator.pop(context); // ?
                        }
                      },
                    )
                  ],
                  content: Text('Conta criada com sucesso!'),
                ),
              );
            },
            context: context);
      } else {
        return _alert(
            'Ocorreu um erro de autenticação, tente novamente mais tarde.',
            login.responseCode);
      }
    } else {
      return _alert('Ocorreu um erro ao cadastrar a senha.', resp.responseCode);
    }
  }

  void _alert(String title, int? errCode) {
    showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                    child: Text('OK'), onPressed: () => Navigator.pop(context))
              ],
              content:
                  Text('$title ${errCode != null ? '(Erro: $errCode)' : ''}'),
            ),
          );
        },
        context: context);
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

  void _showTerms() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PolicyPage(), fullscreenDialog: true));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
