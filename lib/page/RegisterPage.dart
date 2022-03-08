import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/page/LoginPage.dart';
import 'package:afarma/page/RegisterPersonalDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({this.isFromPurchase = false, this.isFromPromocoes = false});

  final bool isFromPurchase;
  final bool isFromPromocoes;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: Container(
          child: _mainBody(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-white.png'),
                  fit: BoxFit.fill)),
          padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
        ),
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        Spacer(flex: 7),
        _welcomeText(),
        Spacer(flex: 1),
        _continueWithButtons(),
        Spacer(flex: 5),
        _backButton(),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _welcomeText() {
    return Text(
      widget.isFromPurchase ? 'Finalize o seu cadastro' : 'Autenticação',
      style: TextStyle(
          color: Color.fromRGBO(67, 67, 67, 1),
          /* dark grey */
          fontSize: 18,
          fontWeight: FontWeight.w500),
    );
  }

  Widget _continueWithButtons() {
    return Column(
      children: [
        LoginPage(
          isFromPromocoes: widget.isFromPromocoes,
        ),
        _createAccountButton(),
      ],
    );
  }

  Widget _createAccountButton() {
    return _redButton('Criar uma conta', () => _createAccount());
  }

  Widget _backButton() {
    return _redButton('Voltar', () {
      Navigator.pop(context, false);
    });
  }

  Widget _redButton(String text, Function action) {
    return Padding(
      child: ButtonTheme(
        child: RaisedButton(
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          color: AppColors.primary,
          /* red */
          onPressed: action as void Function()?,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minWidth: MediaQuery.of(context).size.width - 80,
        height: 45,
      ),
      padding: EdgeInsets.only(bottom: 12.0),
    );
  }

  void _createAccount() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalDetailsPage(
          isFromPurchase: widget.isFromPurchase,
          isFromPromocoes: widget.isFromPromocoes,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
