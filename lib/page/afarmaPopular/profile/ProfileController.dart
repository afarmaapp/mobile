import 'package:afarma/Formatters/CEPFormatter.dart';
import 'package:afarma/Formatters/CPFFormatter.dart';
import 'package:afarma/Formatters/PhoneFormatter.dart';
import 'package:afarma/helper/popularHelpers/Connector.dart';
// import 'package:afarma/page/afarmaPopular/MainTabController.dart';
import 'package:afarma/page/afarmaPopular/profile/EditPersonalDetailsController.dart';
import 'package:afarma/page/afarmaPopular/profile/RegisterController.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:flutter_restart/flutter_restart.dart';

class ProfileController extends StatefulWidget {
  @override
  _ProfileControllerState createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  bool get isDarkMode =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: _mainBuild(),
      ),
    );
  }

  Widget _mainBuild() {
    if (User.instance == null) return Container();
    return SingleChildScrollView(
      child: Column(
        children: [
          //_userProfilePicture(),
          _personalDetailsWidget(),
          _idWidget(),
          // _indicationCodeWidget(),
          _contactWidget(),
          _logoutWidget(),
          AbsorbPointer(
            absorbing: true,
            child: Opacity(opacity: 0.0, child: _logoutWidget()),
          )
        ],
      ),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _userProfilePicture() {
    String imageURL = 'add url';
    return Padding(
      child: Center(
        child: InkWell(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(75),
            child: Image(
              image: NetworkImage(imageURL),
              height: 150,
              width: 150,
            ),
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
    );
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
                  _valueRow('Nome', User.instance!.name!),
                  _valueRow(
                      'CPF',
                      User.instance!.cpf! != null
                          ? CPFFormatter.format(User.instance!.cpf!)
                          : ''),
                  _valueRow('Telefone',
                      PhoneFormatter.format(User.instance!.cellphone))
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
                    'Endereço',
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
                  _valueRow('Rua', 'Francisco Dutra'),
                  _valueRow('Número', 142.toString()),
                  _valueRow('Complemento', 'Apt 1234'),
                  _valueRow('Bairro', 'Icaraí'),
                  _valueRow('CEP', CEPFormatter.format('24220150')),
                  _valueRow('Cidade', 'Niterói'),
                  _valueRow('Estado', 'RJ')
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
      padding: EdgeInsets.all(20),
    );
  }

  Widget _indicationCodeWidget() {
    // String codigoInd = "LUIS01";
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
                Expanded(
                    child: RichText(
                        text: TextSpan(
                            text: 'Código de Indicação:\n',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            children: [
                      TextSpan(
                          text: User.instance!.codigoInd,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600))
                    ]))),
                SizedBox(width: 10.0),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                        new ClipboardData(text: User.instance!.codigoInd));
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

  Widget _idWidget() {
    List<Widget> docWidgets = [];
    if (User.instance!.docIDs != null) {
      User.instance!.docIDs!.forEach((doc) {
        String imageURL = DefaultURL.apiURL() +
            DefaultURI.afarma +
            '/api/v1/Documento/image/$doc';
        docWidgets.add(GestureDetector(
            child: Padding(
              child:
                  Image(image: NetworkImage(imageURL), height: 150, width: 150),
              padding: EdgeInsets.only(right: 20.0),
            ),
            onTap: () => _editUserDetails()));
      });
    }

    return User.instance!.docIDs != null && User.instance!.docIDs!.length > 0
        ? InkWell(
            child: Container(
              child: Column(
                children: [
                  Text(
                      'Documento${User.instance!.docIDs!.length > 1 ? 's' : ''}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 20.0),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: docWidgets,
                        mainAxisAlignment: MainAxisAlignment.center,
                      )),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ],
                  color: Colors.white),
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
            ),
            onTap: () => _editUserDetails(),
          )
        : Container();
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
            'Sim',
            'Não'
          ], [
            () => _performLogout(),
            () => Navigator.pop(context),
          ]);
        },
      ),
      padding: EdgeInsets.all(20),
    );
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
    Future.delayed(Duration(milliseconds: 10)).then((_) async {
      if (User.instance == null) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          final resp = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RegisterController(isFromPurchase: false),
                  fullscreenDialog: true,
                  settings: RouteSettings(name: 'RegisterRoute')));
          if (User.instance == null) {
            _performQuit();
          } else {
            setState(() {});
          }
        });
        /*
        final resp = await Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => RegisterController(isFromPurchase: false),
            fullscreenDialog: true,
            settings: RouteSettings(name: 'RegisterRoute')
          )
        );
        if (User.instance == null) {
          _performQuit();
        } else {
          setState(() { });
        }
        */
      }
    });
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
          return AlertDialog(
            actions: actionsWidget,
            content: Text(title),
          );
        },
        context: context);
  }

  void _sendEmail() async {
    final Email email = Email(recipients: ['contato@afarmaapp.com.br']);
    FlutterEmailSender.send(email);
  }

  void _editUserDetails() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPersonalDetailsController(),
        ));
    setState(() {});
  }

  void _performLogout() async {
    Connector.resetUserKey();
    User.instance = null;
    Navigator.pop(context); // alerta
    // FlutterRestart.restartApp();
    Future.delayed(Duration(milliseconds: 100)).then((value) => _performQuit());
  }

  void _performQuit() {
    if (mounted) setState(() {});
    Navigator.pop(context); // l
    if (mounted) setState(() {});
  }
}
