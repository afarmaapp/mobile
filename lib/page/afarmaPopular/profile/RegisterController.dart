import 'package:afarma/page/afarmaPopular/profile/LoginController.dart';
import 'package:afarma/page/afarmaPopular/profile/PersonalDetailsController.dart';
import 'package:flutter/material.dart';

class RegisterController extends StatefulWidget {
  RegisterController({required this.isFromPurchase});

  bool isFromPurchase;

  @override
  _RegisterControllerState createState() => _RegisterControllerState();
}

class _RegisterControllerState extends State<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _mainBody(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/loginWhiteBackground.png'),
                fit: BoxFit.fill)),
        padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
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
        _backButton()
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
        /*
        _appleButton(),
        _googleButton(),
        _facebookButton(),
        */
        LoginController(),
        //_enterButton(),
        _createAccountButton(),
      ],
    );
  }

  Widget _appleButton() {
    return _socialButton('assets/images/logos/social/appleLogo.png',
        'Continue com Apple', () => _appleLogin());
  }

  Widget _googleButton() {
    return _socialButton('assets/images/logos/social/googleLogo.png',
        'Continue com Google', () => _googleLogin());
  }

  Widget _facebookButton() {
    return _socialButton('assets/images/logos/social/facebookLogo.png',
        'Continue com Facebook', () => _facebookLogin());
  }

  Widget _createAccountButton() {
    return _redButton('Criar uma conta', () => _createAccount());
  }

  Widget _enterButton() {
    return _redButton('Entrar', () => _enter());
  }

  Widget _backButton() {
    return _redButton('Voltar', () => Navigator.pop(context));
  }

  Widget _socialButton(String icon, String text, Function action) {
    return Padding(
      child: ButtonTheme(
        child: RaisedButton(
          child: Row(
            children: [
              Image.asset(
                icon,
                height: 20.0,
                width: 20.0,
              ),
              Spacer(),
              Text(
                text,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Spacer()
            ],
          ),
          color: Colors.white,
          onPressed: action as void Function()?,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        minWidth: MediaQuery.of(context).size.width - 80,
        height: 45,
      ),
      padding: EdgeInsets.only(bottom: 12.0),
    );
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
          color: Color.fromRGBO(255, 49, 49, 1),
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

  void _appleLogin() async {}

  void _googleLogin() async {}

  void _facebookLogin() async {}

  void _createAccount() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PersonalDetailsController(
                isFromPurchase: widget.isFromPurchase),
            fullscreenDialog: true));
  }

  void _enter() async {
    showModalBottomSheet(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) =>
            LoginController(isFromPurchase: widget.isFromPurchase),
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  }
}
