import 'dart:ui';
import 'package:package_info/package_info.dart';
import 'package:afarma/formatters/CPFFormatter.dart';
import 'package:afarma/formatters/PhoneFormatter.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/User.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../RegisterPage.dart';
import '../VersionPage.dart';
import 'ChangeAddressPage.dart';
import 'EditPersonalDetailsPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get isDarkMode => false;
  //MediaQuery.of(context).platformBrightness == Brightness.dark;

  String? localVersion;
  bool isDifferent = false;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();

    // Pega os dados da versão REAL do APP!
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });

    VersionPage.getAppVersion().then((value) {
      localVersion = value;
      setState(() {});
    });

    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: _mainBuild(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainBuild() {
    // Se não tem usuário volta
    if (User.instance == null) {
      return Container();
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _personalDetailsWidget(),
          _addressWidget(),
          _contactWidget(),
          _logoutWidget(),
          _appVersion(),
        ],
      ),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  void _changeAddress() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeAddressPage(),
        ));
  }

  Widget _contactWidget() {
    // alguma duvida? entre em contato
    return Padding(
      child: InkWell(
          child: Container(
            child: Row(
              children: [
                Icon(
                  Icons.mail_outline,
                  color: Colors.grey[700],
                  size: 30,
                ),
                SizedBox(width: 20.0),
                RichText(
                    text: TextSpan(
                        text: 'Alguma dúvida?  ',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                        children: [
                      TextSpan(
                          text: 'Entre em contato',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700))
                    ]))
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 2),
                      spreadRadius: 1.0)
                ],
                color: Colors.white),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
          ),
          onTap: () => _sendEmail()),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _appVersion() {
    if (localVersion != null) {
      return Container(
        padding: EdgeInsets.only(bottom: 10),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: '$localVersion\nApp Version: $version ($buildNumber)',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black)),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _personalDetailsWidget() {
    return Padding(
      child: InkWell(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Colors.grey[700],
                    size: 30.0,
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Dados Pessoais',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              ),
              Padding(
                child: Divider(
                  color: Colors.grey,
                  height: 1.0,
                  thickness: 0.5,
                ),
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Column(
                children: [
                  _valueRow('Nome',
                      User.instance!.name != null ? User.instance!.name : ''),
                  _valueRow(
                      'CPF',
                      User.instance!.cpf != null
                          ? CPFFormatter.format(User.instance!.cpf!)
                          : ''),
                  _valueRow(
                      'Telefone',
                      User.instance!.cellphone != null
                          ? PhoneFormatter.format(User.instance!.cellphone)
                          : '')
                ],
              )
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    blurRadius: 10.0,
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 2),
                    spreadRadius: 1.0)
              ],
              color: Colors.white),
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width - 40,
        ),
        onTap: () => _editUserDetails(),
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _addressWidget() {
    return Padding(
      child: InkWell(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_searching,
                    color: isDarkMode ? Colors.white : Colors.grey[700],
                    size: 30,
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    'Endereço de Entrega',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 15),
                  ),
                ],
              ),
              Padding(
                child: Divider(
                  color: Colors.grey,
                  height: 1.0,
                  thickness: 0.5,
                ),
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Column(
                children: [
                  ButtonTheme(
                      child: RaisedButton(
                    child: AutoSizeText(
                      'Ver Meus Endereços',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w300),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    color: Colors.grey,
                    onPressed: () => _changeAddress(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ))
                ],
              )
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    blurRadius: 10.0,
                    color: (isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.5),
                    offset: Offset(0, 2),
                    spreadRadius: 1.0)
              ],
              color: isDarkMode ? Colors.black : Colors.white),
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width - 40,
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    );
  }

  Widget _indicationCodeWidget() {
    String codigoInd = "LUIS01";
    // alguma duvida? entre em contato
    return Padding(
      child: InkWell(
          child: Container(
            child: Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: Colors.grey[700],
                  size: 30,
                ),
                SizedBox(width: 15.0),
                // Expanded(
                //     child: RichText(
                //         text: TextSpan(
                //             text: 'Código de Indicação:\n',
                //             style: TextStyle(color: Colors.black, fontSize: 12),
                //             children: [
                //       TextSpan(
                //           text: codigoInd,
                //           style: TextStyle(
                //               color: Colors.black,
                //               fontSize: 28,
                //               letterSpacing: 1.5,
                //               fontWeight: FontWeight.w600))
                //     ]))),
                // SizedBox(width: 10.0),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(new ClipboardData(text: codigoInd));
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'O código de indicação foi copiado!',
                          textAlign: TextAlign.center,
                        ),
                        duration: const Duration(milliseconds: 3000),
                        width: 280.0, // Width of the SnackBar.
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              8.0, // Inner padding for SnackBar content.
                        ),
                        backgroundColor: Colors.red[400],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  },
                  child: Text('COPIAR',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w400)),
                )
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 2),
                      spreadRadius: 1.0)
                ],
                color: Colors.white),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
          ),
          onTap: () => _sendEmail()),
      padding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 20),
    );
  }

  Widget _logoutWidget() {
    return Padding(
        child: InkWell(
          child: Container(
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.grey[700],
                  size: 30,
                ),
                SizedBox(width: 20.0),
                Text(
                  'Sair',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 2),
                      spreadRadius: 1.0)
                ],
                color: Colors.white),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
          ),
          onTap: () {
            _alert('Tem certeza que deseja sair?', false, [
              'Não',
              'Sim',
            ], [
              () => Navigator.pop(context),
              () => _performLogout(),
            ]);
          },
        ),
        padding: EdgeInsets.only(bottom: 20));
  }

  Widget _valueRow(String left, String right) {
    return Padding(
      child: Row(
        children: [
          Text(
            left,
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            right,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
    );
  }

  void _checkLogin() async {
    if (User.instance == null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        // Manda para a tela de registro/login
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(isFromPurchase: false),
            fullscreenDialog: true,
            settings: RouteSettings(name: 'RegisterRoute'),
          ),
        ).then((value) {
          // Quando ocorre o retorno da página de registro!!!
          if (User.instance == null) {
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            setState(() {});
          }
        });
      });
    }
  }

  void _alert(String title, bool dismissible, List<String> actionTitles,
      List<Function> actions) {
    List<Widget> actionsWidget = [];
    int index = 0;
    actionTitles.forEach((title) {
      actionsWidget.add(FlatButton(
        child: Text(title),
        onPressed: actions[index] as void Function()?,
      ));
      index++;
    });
    showDialog(
        barrierDismissible: dismissible,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: actionsWidget,
              content: Text(title),
            ),
          );
        },
        context: context);
  }

  void _sendEmail() async {
    final Email email = Email(recipients: ['contato@afarmaapp.com.br']);
    FlutterEmailSender.send(email).onError((error, stackTrace) {
      _alert(
          'Ocorreu um erro, verifique se existe algum cliente de e-mail instalado.',
          false, [
        'Entendi!',
      ], [
        () => Navigator.pop(context),
      ]);
    });
  }

  void _editUserDetails() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonalDetailsPage(),
      ),
    ).then((value) {
      setState(() {});
    });
  }

  void _performLogout() async {
    Connector.logout().then((value) {
      Navigator.pop(context); // alert
      if (mounted) setState(() {});
      Navigator.pop(context); // login
    });
  }
}
