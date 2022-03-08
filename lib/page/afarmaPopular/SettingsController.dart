import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/page/afarmaPopular/completePurchase/ChangeAddressController.dart';
import 'package:afarma/page/afarmaPopular/profile/RegisterController.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:flutter/material.dart';

class _SettingsOption {
  _SettingsOption({this.icon, this.title, this.subtitle, this.onPressed});

  ImageProvider? icon;
  String? title;
  String? subtitle;
  Function? onPressed;
}

class SettingsController extends StatefulWidget {
  @override
  _SettingsControllerState createState() => _SettingsControllerState();
}

class _SettingsControllerState extends State<SettingsController> {
  List<_SettingsOption> options = [];

  @override
  void initState() {
    super.initState();
    _updateOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: Text(
          'Configurações',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: _mainWidget(),
      ),
    );
  }

  Widget _mainWidget() {
    return ListView.builder(
      itemBuilder: (context, index) {
        _SettingsOption opt = options[index];
        return Card(
          child: ListTile(
            /*
            leading: Image(
              image: opt.icon ?? AssetImage(''),
            ),*/
            //subtitle: Text(opt.subtitle),
            title: Text(opt.title!),
            onTap: opt.onPressed as void Function()?,
          ),
        );
      },
      itemCount: options.length,
      scrollDirection: Axis.vertical,
    );
  }

  void _signIn() async {
    final resp = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterController(isFromPurchase: false),
            settings: RouteSettings(name: 'PersonalDetailsRoute')));
    _updateOptions();
    setState(() {});
  }

  void _logout() async {
    await Connector.logout();
    _updateOptions();
    setState(() {});
  }

  void _updateOptions() {
    options.clear();
    if (User.instance == null) {
      options.add(
        _SettingsOption(
            icon: null,
            title: 'Entrar',
            subtitle: '',
            onPressed: () => _signIn()),
      );
    } else {
      options.addAll([
        _SettingsOption(
            icon: null,
            title: 'Ver endereços',
            subtitle: '',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => User.instance != null
                          ? ChangeAddressController()
                          : RegisterController(isFromPurchase: false),
                      settings: User.instance != null
                          ? null
                          : RouteSettings(name: 'PersonalDetailsRoute')));
            }),
        _SettingsOption(
            icon: null, title: 'Sair', subtitle: '', onPressed: () => _logout())
      ]);
    }
  }
}
