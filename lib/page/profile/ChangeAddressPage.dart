import 'dart:ui';

import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/GoogleLocation.dart';
import 'package:afarma/page/profile/AddAddressPage.dart';
import 'package:afarma/repository/AddressRepository.dart';
import 'package:afarma/service/LocationServices.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ChangeAddressPage extends StatefulWidget {
  @override
  _ChangeAddressPageState createState() => _ChangeAddressPageState();
}

class _ChangeAddressPageState extends State<ChangeAddressPage> {
  List<Address> get _addresses => AddressRepository().addresses;
  Address? _currentLocation;

  @override
  void initState() {
    super.initState();
    AddressRepository().getAllAddresses();
    AddressRepository().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: Text(
          'Endereços de Entrega',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: _mainBody(),
      ),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.0, width: MediaQuery.of(context).size.width),
          _useLocationCell(),
          Column(
            children:
                _addresses.map((address) => _addressCell(address)).toList(),
          ),
          _addAddressButton(),
          SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _useLocationCell() {
    return Padding(
      child: GestureDetector(
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                  size: 24,
                ),
                flex: 20,
              ),
              Spacer(flex: 5),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Usar minha localização',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Liberar uso de localização',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                flex: 80,
              ),
              Spacer(flex: 5)
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
        onTap: () => _getCurrentLocation(),
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget _addressCell(Address address) {
    bool isSelected = (address == AddressRepository().selectedAddress);
    TextStyle defaultTextStyle = TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.w300);
    return Padding(
      child: GestureDetector(
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Icon(
                    Icons.home,
                    color: isSelected ? Colors.white : Colors.black,
                    size: 32,
                  ),
                  flex: 20,
                ),
                Spacer(flex: 5),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        child: Text(
                          address.description ?? '',
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        padding: EdgeInsets.only(bottom: 5.0),
                      ),
                      AutoSizeText(
                        '${address.street ?? ''}, ${address.number ?? ''}',
                        maxLines: 1,
                        style: defaultTextStyle,
                      ),
                      AutoSizeText(
                        address.neighborhood!,
                        maxLines: 1,
                        style: defaultTextStyle,
                      ),
                      AutoSizeText(
                        '${address.city ?? ''}/${address.state ?? ''}',
                        maxLines: 1,
                        style: defaultTextStyle,
                      ),
                      AutoSizeText(
                        address.complement ?? '',
                        maxLines: 1,
                        style: defaultTextStyle,
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  flex: 70,
                ),
                Spacer(flex: 5),
                Expanded(
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primary /* red */,
                    ),
                    onPressed: () => _displayAddressOptions(address),
                  ),
                  flex: 10,
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
                color: isSelected ? AppColors.primary /* red */ : Colors.white),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40,
          ),
          onTap: () => _selectedAddress(address)),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget _addAddressButton() {
    return SizedBox(
      child: ButtonTheme(
        child: RaisedButton(
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              SizedBox(width: 15.0),
              Text(
                'Adicionar Endereço',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          color: AppColors.secondary,
          /* blue */
          onPressed: () => _addAddress(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        minWidth: MediaQuery.of(context).size.width - 80,
        height: 45,
      ),
      width: MediaQuery.of(context).size.width - 40,
    );
  }

  void _displayAddressOptions(Address address) async {
    final a = await showModalBottomSheet(
        builder: (context) => Container(
              child: Column(
                children: [
                  Text(
                    address.street ?? '',
                    style: TextStyle(
                        color: Color.fromRGBO(67, 67, 67, 1),
                        /* dark grey */
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          child: RaisedButton(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_circle,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  'Excluir',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            color: Color.fromRGBO(67, 67, 67, 1),
                            /* dark grey */
                            onPressed: () => _removeAddress(address),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          height: 50,
                        ),
                        flex: 45,
                      ),
                      //Spacer(flex: 10),

                      /*
                Expanded(
                  child: ButtonTheme(
                    child: RaisedButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      color: Color.fromRGBO(67, 67, 67, 1), /* dark grey */
                      onPressed: () {

                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    height: 50,
                  ),
                  flex: 45,
                ),
                */
                    ],
                  ),
                  SizedBox(height: 20.0),
                  FlatButton(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.only(
                  top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
            ),
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
  }

  void _getCurrentLocation() async {
    _loadingAlert('Pegando sua localizaçäo...');
    GoogleLocation? loc = await LocationServices.currentLocation();
    if (loc == null) {
      Navigator.pop(context);
      return _alert(
          'Ocorreu um erro ao pegar a sua localizaçäo atual, verifique a permissão para o aplicatido da aFarma utilizar o GPS do dispositivo.');
    }
    if (!mounted) return;
    if (loc == null) {
      Navigator.pop(context);
      return _alert(
          'Ocorreu um erro ao pegar a sua localizaçäo atual, tente novamente mais tarde');
    }
    Navigator.pop(context); // alerta
    if (loc.isBrazil()) {
      _currentLocation = loc.toAddress();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddAddressPage(googleAddress: _currentLocation),
          ));
    } else {
      _alert(
          'Sua localização atual não pode ser utilizada pois não se localiza no Brasil');
    }
    //AddressRepository().selectAddress(_currentLocation, true);
    //Navigator.pop(context); // tela
  }

  void _addAddress() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAddressPage(),
        ));
  }

  void _selectedAddress(Address address) {
    AddressRepository().selectAddress(address, false);
    Navigator.pop(context, {
      'address': address,
      'isCurrent': false,
    });
  }

  void _loadingAlert(String title) {
    showDialog(
        barrierDismissible: true,
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

  void _alert(String content) {
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
              content: Text(content),
            ),
          );
        },
        context: context);
  }

  void _removeAddress(Address address) async {
    final resp = await AddressRepository().removeAddress(address);
    showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ],
              content: Text(resp! < 400
                  ? 'Endereço removido com sucesso!'
                  : 'Ocorreu um erro ao remover o endereço. (Erro: $resp)'),
            ),
          );
        },
        context: context);
  }

  @override
  void dispose() {
    AddressRepository().removeListener(() {});
    super.dispose();
  }
}
