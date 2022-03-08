import 'package:afarma/page/afarmaPopular/WalkthroughController.dart';
import 'package:afarma/page/afarmaPopular/profile/SignUpController.dart';
import 'package:flutter/material.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SignInController extends StatefulWidget {
  @override
  _SignInControllerState createState() => _SignInControllerState();
}

class _SignInControllerState extends State<SignInController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _mainBody(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/images/backgrounds/loginRedBackground.png'),
                fit: BoxFit.fill)),
        padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        Spacer(flex: 5),
        _logoImage(),
        Spacer(flex: 1),
        _welcomeText(),
        Spacer(flex: 1),
        _continueWithButtons(),
        SizedBox(height: 15.0),
        _orText(),
        SizedBox(
          height: 25.0,
        ),
        _guestButton(),
        Spacer(flex: 5)
      ],
    );
  }

  Widget _logoImage() {
    return Image.asset(
      'assets/images/logos/farmaLogo.png',
      height: MediaQuery.of(context).size.width / 3,
      width: MediaQuery.of(context).size.width / 3,
    );
  }

  Widget _welcomeText() {
    return Text(
      'Bem vindo ao afarma',
      style: TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
    );
  }

  Widget _continueWithButtons() {
    return Column(
      children: [_appleButton(), _googleButton(), _createAccountButton()],
    );
  }

  Widget _appleButton() {
    return _socialButton(Icon(Icons.ac_unit), 'Continue com Apple', () {});
  }

  Widget _googleButton() {
    return _socialButton(Icon(Icons.ac_unit), 'Continue com Google', () {});
  }

  Widget _createAccountButton() {
    return _socialButton(
        Container(), 'Criar uma conta', () => _createAccount());
  }

  Widget _socialButton(Widget leading, String text, Function action) {
    return Padding(
      child: ButtonTheme(
        child: RaisedButton(
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.access_alarm,
                  size: 30,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              )
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

  Widget _orText() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'ou',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _guestButton() {
    return _socialButton(Container(), 'Entre como convidado', () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WalkthroughController(),
              fullscreenDialog: true));
    });
  }

  void _appleLogin() async {}

  void _googleLogin() async {}

  void _createAccount() async {
    showModalBottomSheet(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => SignUpController(),
        context: context,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)));
  }
}
