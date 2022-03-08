import 'package:afarma/page/afarmaPopular/WalkthroughController.dart';
import 'package:flutter/material.dart';

class SignUpController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _mainBody(context),
      padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
    );
  }

  Widget _mainBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _quitIconButton(context),
          _createYourAccountText(context),
          _inputTextFields(context),
          _loginButton(context)
        ],
      ),
    );
  }

  Widget _quitIconButton(BuildContext context) {
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

  Widget _createYourAccountText(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Crie sua conta',
        style: TextStyle(
            color: Color.fromRGBO(255, 49, 49, 1),
            /* red */
            fontSize: 22,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _inputTextFields(BuildContext context) {
    double heightSeparation = 12.0;
    return Column(
      children: [
        SizedBox(height: heightSeparation),
        _textField('Email', false, (val) {}),
        SizedBox(height: heightSeparation),
        _textField('Celular', false, (val) {}),
        SizedBox(height: heightSeparation),
        _textField('Senha', true, (val) {}),
        SizedBox(height: heightSeparation),
        _textField('Repita a senha', true, (val) {}),
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
      onChanged: fun,
      onSubmitted: fun,
      style: TextStyle(color: Colors.black),
      textCapitalization: TextCapitalization.none,
      textAlign: TextAlign.left,
    );
  }

  Widget _loginButton(BuildContext context) {
    return ButtonTheme(
      child: RaisedButton(
        child: Text(
          'LOGIN',
          style: TextStyle(color: Colors.white),
        ),
        color: Color.fromRGBO(255, 49, 49, 1),
        /* red */
        onPressed: () => _performSignUp(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      minWidth: MediaQuery.of(context).size.width - 40,
      height: 50,
    );
  }

  void _performSignUp(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WalkthroughController(),
            fullscreenDialog: true));
  }
}
