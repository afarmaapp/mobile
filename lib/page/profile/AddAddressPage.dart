import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/GoogleLocation.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/repository/AddressRepository.dart';
import 'package:afarma/service/LocationServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

List<String> states = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MG',
  'MS',
  'MT',
  'PA',
  'PB',
  'PE',
  'PI',
  'PR',
  'RJ',
  'RN',
  'RO',
  'RR',
  'RS',
  'SC',
  'SE',
  'SP',
  'TO'
];

String _defaultGoogleAddressName = 'Minha localização';

class AddAddressPage extends StatefulWidget {
  AddAddressPage({
    this.googleAddress,
  });

  Address? googleAddress;

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _streamController = StreamController<Address>();
  final _streamInputController = StreamController<Address>();

  static Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  String? _searchedCEP;
  GoogleLocation? _searchedGoogleLocation;

  bool? _isCurrent;

  Address _newAddress = Address(located: true);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MaskTextInputFormatter _cepFormatter = MaskTextInputFormatter(
      mask: '#####-###', filter: {'#': RegExp(r'[0-9]')});

  TextEditingController _nameController = TextEditingController();
  TextEditingController _cepController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _complementController = TextEditingController();
  TextEditingController _neighborhoodController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();

  String? googleAPIKey;

  @override
  void initState() {
    super.initState();

    if (widget.googleAddress != null) {
      _nameController.text = _defaultGoogleAddressName;
      _cepController.text = widget.googleAddress!.cep!;
      _streetController.text = widget.googleAddress!.street!;
      _numberController.text = widget.googleAddress!.number!;
      // _complementController.text = widget.googleAddress!.complement!; // Nunca terá complemento
      _neighborhoodController.text = widget.googleAddress!.neighborhood!;
      _cityController.text = widget.googleAddress!.city!;
      _stateController.text = widget.googleAddress!.state!;

      _streamController.add(widget.googleAddress!);
      _streamInputController.add(widget.googleAddress!);
    }

    LocationServices.getAPIKey().then((value) {
      googleAPIKey = value;
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
          'Adicionar Endereço',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: _mainBody(),
        padding: EdgeInsets.only(top: 30.0),
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
    );
  }

  String? checkIfIsSearched() {
    if (_searchedGoogleLocation != null || _newAddress != null) {
      return 'Uhuuul, Searched!!';
    }
    return null;
  }

  Widget _mainBody() {
    Address currentAddress = widget.googleAddress ?? _newAddress;
    bool shouldBlock =
        _searchedCEP != null && _searchedCEP == _cepFormatter.getUnmaskedText();
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            child: Column(
              children: [
                _textField(false, 'Nome do Endereço (Casa, Trabalho...)',
                    _nameController, [], TextInputType.name, (val) {
                  currentAddress.description = val;
                }, null),
                Focus(child: Builder(builder: (BuildContext context) {
                  final FocusNode focusNode = Focus.of(context);
                  final bool hasFocus = focusNode.hasFocus;

                  return _textField(false, 'CEP', _cepController,
                      [_cepFormatter], TextInputType.number, (val) {
                    currentAddress.cep = _cepFormatter.getUnmaskedText();
                  }, null);
                })),
                // _textField(false, 'CEP', _cepController, [_cepFormatter],
                //     TextInputType.number, (val) {
                //   currentAddress.cep = _cepFormatter.getUnmaskedText();
                // }, null),
                StreamBuilder(
                    stream: _streamController.stream,
                    builder: (BuildContext context, snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        print('Snapshot: $snapshot');
                        children = <Widget>[
                          _textField(
                              (shouldBlock &&
                                  _searchedGoogleLocation != null &&
                                  _searchedGoogleLocation!.street!.isValid()),
                              'Rua',
                              _streetController,
                              [],
                              TextInputType.streetAddress, (val) {
                            currentAddress.street = val;
                          }, null),
                          _textField(
                              (shouldBlock &&
                                  _searchedGoogleLocation != null &&
                                  _searchedGoogleLocation!.number!.isValid()),
                              'Número',
                              _numberController,
                              [],
                              TextInputType.number, (val) {
                            currentAddress.number = val;
                          }, null),
                          _textField(
                              false,
                              'Complemento',
                              _complementController,
                              [],
                              TextInputType.streetAddress, (val) {
                            currentAddress.complement = val;
                          }, null),
                          _textField(
                              (shouldBlock &&
                                  _searchedGoogleLocation != null &&
                                  _searchedGoogleLocation!.neighborhood!
                                      .isValid()),
                              'Bairro',
                              _neighborhoodController,
                              [],
                              TextInputType.streetAddress, (val) {
                            currentAddress.neighborhood = val;
                          }, null),
                          _textField(
                              (shouldBlock &&
                                  _searchedGoogleLocation != null &&
                                  _searchedGoogleLocation!.neighborhood!
                                      .isValid()),
                              'Cidade',
                              _cityController,
                              [],
                              TextInputType.streetAddress, (val) {
                            currentAddress.city = val;
                          }, null),
                          _textField(
                              (shouldBlock &&
                                  _searchedGoogleLocation != null &&
                                  _searchedGoogleLocation!.state!.isValid()),
                              'Estado',
                              _stateController,
                              [],
                              TextInputType.streetAddress, (val) {
                            currentAddress.state = val;
                          }, null),
                        ];
                      } else {
                        children = const <Widget>[SizedBox(height: 20.0)];
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: children,
                        ),
                      );
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
          ),
          SizedBox(height: 20.0),
          StreamBuilder(
              stream: _streamInputController.stream,
              builder: (BuildContext context, snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
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
                        onPressed: () => _saveAndQuit(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      height: 50,
                      minWidth: MediaQuery.of(context).size.width - 40,
                    )
                  ];
                } else {
                  children = <Widget>[
                    ButtonTheme(
                      child: RaisedButton(
                        child: Text(
                          'Buscar CEP',
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        color: AppColors.secondary,
                        /* blue */
                        onPressed: () => {_searchCEP()},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      height: 50,
                      minWidth: MediaQuery.of(context).size.width - 40,
                    )
                  ];
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                );
              }),
          SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _textField(
      bool blocked,
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
        suffixIcon: title.toLowerCase() != 'cep'
            ? null
            : IconButton(
                icon: Icon(Icons.search), onPressed: () => {_searchCEP()}),
      ),
      inputFormatters: formatters,
      enableSuggestions: false,
      expands: false,
      keyboardType: keyboardType,
      maxLines: 1,
      onEditingComplete: title.toLowerCase() != 'cep' ? null : _searchCEP,
      obscureText: false,
      onChanged: onSubmitted,
      onSubmitted: (val) {
        onSubmitted(val);
        setState(() {});
      },
      textCapitalization: TextCapitalization.none,
      style: TextStyle(color: Colors.black),
    );
    return Padding(
      child: Column(
        children: [
          (title.toLowerCase() == 'estado' || blocked)
              ? GestureDetector(
                  child: AbsorbPointer(child: ret),
                  onTap: (title.toLowerCase() == 'estado')
                      ? () => _selectState(controller)
                      : () {})
              : ret,
          (bottom != null) ? bottom : Container()
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  // Widget testingWidget() {
  //   return FutureBuilder(
  //       future: _searchCEP(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           return Text('Passou no Testeem');
  //         }

  //         return Text('Aguarding');
  //       });
  // }

  // Future<void> requestPermission() async {
  //   if (Platform.isAndroid) {
  //     if (await Permission.location.request().isGranted) {
  //       return;
  //     } else {
  //       print('Aplicação não autorizada');

  //       await showDialog(
  //           builder: (context) {
  //             return AlertDialog(
  //               actions: [
  //                 FlatButton(
  //                   child: Text('Ok'),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ].reversed.toList(),
  //               content: Text(
  //                 'Para continuar você precisa dar permissão para a localização, tente novamente.',
  //                 textAlign: TextAlign.center,
  //               ),
  //             );
  //           },
  //           context: context);

  //       return;
  //     }
  //   }
  // }

  Future<void> _searchCEP() async {
    if (googleAPIKey == null) {
      _alert('Ocorreu um erro com a API do Google, contate o administrador.');
      return;
    }
    // await requestPermission();

    if (_cepFormatter.getUnmaskedText() == null ||
        _cepFormatter.getUnmaskedText() == '' ||
        _cepFormatter.getUnmaskedText().length < 8) {
      return _clearFields();
    }

    _loadingAlert('Buscando CEP...');

    // Para mim no Google não esta trazendo a RUA! Talvez com o VIA CEP funcione!
    //'https://viacep.com.br/ws/${_cepFormatter.getUnmaskedText()}/json/'

    final response = await _connector.getContent(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${_cepFormatter.getUnmaskedText()}&key=$googleAPIKey');

    var parsedResp = jsonDecode(response.returnBody!);
    if (parsedResp.containsKey('status')) {
      String status = parsedResp['status'];
      if (status == 'ZERO_RESULTS') {
        final responseZero = await _connector.getContent(
            'https://maps.googleapis.com/maps/api/geocode/json?address=${_cepFormatter.getMaskedText()}&key=$googleAPIKey');
        parsedResp = jsonDecode(responseZero.returnBody!);
        if (parsedResp['status'] == 'ZERO_RESULTS') {
          Navigator.pop(context);
          _alert(
              'Não conseguimos encontrar seu endereço, por favor preencha o CEP corretamente e tente novamente');

          return;
        }
      }
    }

    _searchedCEP = _cepFormatter.getUnmaskedText();
    List results = parsedResp['results'] ?? [];
    if (results.first != null) {
      GoogleLocation location = GoogleLocation.fromJSON(results.first);
      _searchedGoogleLocation = location;
      // _searchedCEP

      if (widget.googleAddress != null) {
        if (widget.googleAddress!.cep != location.postalCode!.longName) {
          widget.googleAddress!.cep = location.postalCode!.isValid()
              ? location.postalCode!.longName
              : null;
          _cepController.text = (location.postalCode!.isValid()
              ? location.postalCode!.longName
              : '')!;

          widget.googleAddress!.street =
              location.street!.isValid() ? location.street!.longName : null;
          _streetController.text =
              (location.street!.isValid() ? location.street!.longName : '')!;

          widget.googleAddress!.neighborhood = location.neighborhood!.isValid()
              ? location.neighborhood!.longName
              : null;
          _neighborhoodController.text = (location.neighborhood!.isValid()
              ? location.neighborhood!.longName
              : '')!;

          widget.googleAddress!.city =
              location.city!.isValid() ? location.city!.longName : null;
          _cityController.text =
              (location.city!.isValid() ? location.city!.longName : '')!;

          widget.googleAddress!.state =
              location.state!.isValid() ? location.state!.shortName : null;
          _stateController.text =
              (location.state!.isValid() ? location.state!.shortName : '')!;

          widget.googleAddress!.position = location.location;

          _streamController.add(widget.googleAddress!);
          _streamInputController.add(widget.googleAddress!);
          Navigator.pop(context);
        }
      } else {
        _newAddress.cep = location.postalCode!.isValid()
            ? location.postalCode!.longName
            : null;
        _cepController.text = (location.postalCode!.isValid()
            ? location.postalCode!.longName
            : '')!;

        _newAddress.street =
            location.street!.isValid() ? location.street!.longName : null;
        _streetController.text =
            (location.street!.isValid() ? location.street!.longName : '')!;

        _newAddress.neighborhood = location.neighborhood!.isValid()
            ? location.neighborhood!.longName
            : null;
        _neighborhoodController.text = (location.neighborhood!.isValid()
            ? location.neighborhood!.longName
            : '')!;

        _newAddress.city =
            location.city!.isValid() ? location.city!.longName : null;
        _cityController.text =
            (location.city!.isValid() ? location.city!.longName : '')!;

        _newAddress.state =
            location.state!.isValid() ? location.state!.shortName : null;
        _stateController.text =
            (location.state!.isValid() ? location.state!.shortName : '')!;

        _newAddress.position = location.location;

        _streamController.add(_newAddress);
        _streamInputController.add(_newAddress);
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
      _alert(
          'Não conseguimos acesso ao seu sistema de localização, tente novamente fechando e abrindo o aplicativo!');
    }
  }

  void _clearFields() {
    if (widget.googleAddress! != null) {
      //widget.googleAddress!.cep = ;
      //_cepController.text = newCEP;

      widget.googleAddress!.street = '';
      _streetController.text = '';

      widget.googleAddress!.neighborhood = '';
      _neighborhoodController.text = '';

      widget.googleAddress!.city = '';
      _cityController.text = '';

      widget.googleAddress!.state = '';
      _stateController.text = '';
    } else {
      //_newAddress.cep = newCEP;
      //_cepController.text = newCEP;

      _newAddress.street = '';
      _streetController.text = '';

      _newAddress.neighborhood = '';
      _neighborhoodController.text = '';

      _newAddress.city = '';
      _cityController.text = '';

      _newAddress.state = '';
      _stateController.text = '';
    }
  }

  void _saveAndQuit() {
    if (User.instance == null) {
      _alert('Autentique-se antes de adicionar um endereço');
      return;
    }
    if (_searchedGoogleLocation == null && widget.googleAddress == null) {
      _alert(
          'Não há informações sobre sua localização, porfavor aperte o botão da lupa ao lado do seu CEP');
      _clearFields();
      return;
    }
    if ((widget.googleAddress != null && widget.googleAddress!.canBeAdded()) ||
        _newAddress.canBeAdded()) {
      return _addAddress();
    } else {
      _alert('Preencha todos os campos e tente novamente');
    }
  }

  //RONALDO, estamos recebendo erro 500 aqui ao cadastrar endereço... precisamos encontrar o erro juntos
  void _addAddress() async {
    if (widget.googleAddress != null) {
      if (widget.googleAddress!.position == null) {
        _alert(
            'Não conseguimos encontrar seu endereço, por favor preencha o CEP corretamente e tente novamente');
        return;
      }
      if (widget.googleAddress!.description == null ||
          widget.googleAddress!.description == _defaultGoogleAddressName) {
        DateTime now = DateTime.now();
        widget.googleAddress!.description =
            'Última localização em ${now.day >= 10 ? now.day.toString() : '0' + now.day.toString()}/${now.month >= 10 ? now.month.toString() : '0' + now.month.toString()}';
      }
      AddressRepository().addAddress(widget.googleAddress!).then((resp) {
        AddressRepository().selectAddress(widget.googleAddress!, false);
        if (resp! < 400) {
          // essa tela
          Navigator.pop(context, {
            'address': widget.googleAddress!,
            'isCurrent': false,
          });
          // ChangeAddressController
          Navigator.pop(context, {
            'address': widget.googleAddress!,
            'isCurrent': false,
          });
        } else {
          _alert(
              'Ocorreu um erro ao salvar o endereço na sua lista, tente novamente mais tarde (Erro: $resp)');
        }
      });
      return;
    }
    if (_isCurrent != null) {
      if (_isCurrent!) {
        LocationData currentLocation =
            (await LocationServices.currentLocationCoords())!;
        _newAddress.position =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      }
    } else {
      _isCurrent = await _askIfCurrentAddress();
    }
    if (_newAddress.position == null) {
      if (_searchedCEP == null || _searchedCEP!.trim() == '') {
        _searchCEP().then((_) => _addAddress());
        return;
      }
      _alert(
          'Não conseguimos encontrar seu endereço, por favor preencha o CEP corretamente e tente novamente');
      return;
    }
    AddressRepository().addAddress(_newAddress).then((resp) {
      if (resp! < 400) {
        AddressRepository().selectAddress(_newAddress, _isCurrent!);
        // essa tela
        Navigator.pop(context, {
          'address': _newAddress,
          'isCurrent': _isCurrent,
        });
        // ChangeAddressController
        Navigator.pop(context, {
          'address': _newAddress,
          'isCurrent': _isCurrent,
        });
      } else {
        _alert(
            'Ocorreu um erro ao adicionar um novo endereço, tente novamente mais tarde (Erro: $resp)');
      }
    });
  }

  Future<bool> _askIfCurrentAddress() async {
    bool ret = false;
    final a = await showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    ret = true;
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Não'),
                  onPressed: () {
                    ret = false;
                    Navigator.pop(context);
                  },
                ),
              ],
              content: Text('Você está nesse local?'),
            ),
          );
        },
        context: context);
    return ret;
  }

  void _selectState(TextEditingController controller) async {
    Picker statePicker = Picker(
        adapter: PickerDataAdapter<String>(pickerdata: states),
        onConfirm: (picker, selecteds) {
          controller.text = picker.getSelectedValues()[0];
          _newAddress.state = picker.getSelectedValues()[0];
        },
        onSelect: (picker, idx, items) {
          controller.text = picker.getSelectedValues()[idx];
          _newAddress.state = picker.getSelectedValues()[idx];
        },
        onCancel: () {});
    statePicker.show(_scaffoldKey.currentState!);
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
