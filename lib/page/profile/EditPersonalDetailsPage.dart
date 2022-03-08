import 'dart:ui';

import 'package:afarma/Formatters/CPFFormatter.dart';
import 'package:afarma/Formatters/PhoneFormatter.dart';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/EditedPersonalDetails.dart';
import 'package:afarma/model/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EditPersonalDetailsPage extends StatefulWidget {
  @override
  _EditPersonalDetailsPageState createState() =>
      _EditPersonalDetailsPageState();
}

class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage> {
  Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  MaskTextInputFormatter _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  EditedPersonalDetails _personalDetails =
      EditedPersonalDetails.fromUser(User.instance);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = User.instance!.name;
    _cpfController.text = CPFFormatter.format(User.instance!.cpf!);
    _phoneController.text = PhoneFormatter.format(User.instance!.cellphone);
    _emailController.text = User.instance!.email;
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
        ),
      ),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            child: Column(
              children: [
                _textField(
                    'Nome Completo', _nameController, [], TextInputType.name,
                    (val) {
                  _personalDetails.name = val;
                }, null),
                _textField('CPF', _cpfController, [_cpfFormatter],
                    TextInputType.number, (val) {
                  _personalDetails.cpf = _cpfFormatter.getUnmaskedText();
                }, null),
                _textField('Celular', _phoneController, [_phoneFormatter],
                    TextInputType.number, (val) {
                  _personalDetails.phone = _phoneFormatter.getUnmaskedText();
                },
                    Text(
                      'Insira um número com DDD e 9 dígitos',
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    )),
                _textField(
                    'Email', _emailController, [], TextInputType.emailAddress,
                    (val) {
                  _personalDetails.email = val;
                }, null),
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
                _saveAndQuit();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            height: 50,
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _textField(
      String title,
      TextEditingController controller,
      List<TextInputFormatter> formatters,
      TextInputType keyboardType,
      Function(String) onSubmitted,
      Widget? bottom) {
    final ret = TextField(
      autocorrect: false,
      autofocus: false,
      controller: controller,
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
    _loadingAlert('Enviando mudanças...');
    if (_personalDetails.hasChanges()) {
      if (_personalDetails.canConfirm()) {
        await _updateUserDetails();

        await User.fetch();

        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
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
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Future<void> _updateUserDetails() async {
    String body = _personalDetails.changesToJSON();
    final resp =
        await _connector.putContentWithBody('/api/v1/Usuario/mergehalf', body);
    if (resp.responseCode! < 400) {
      _personalDetails.applyChangesToUser();
    } else {
      _alert(
          'Ocorreu um erro ao salvar suas alterações, tente novamente mais tarde',
          resp.responseCode);
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

  @override
  void dispose() {
    super.dispose();
  }
}
