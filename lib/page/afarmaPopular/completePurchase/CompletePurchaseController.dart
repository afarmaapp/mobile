import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:afarma/formatters/CPFFormatter.dart';
import 'package:afarma/formatters/MoneyFormatter/MoneyFormatter.dart';
import 'package:afarma/formatters/PhoneFormatter.dart';
import 'package:afarma/helper/CurrentDeviceInfo.dart';
import 'package:afarma/helper/popularHelpers/Connector.dart';
import 'package:afarma/model/popularModels/Address.dart';
import 'package:afarma/model/popularModels/Purchase.dart';
import 'package:afarma/page/afarmaPopular/ViewImageWidget.dart';
import 'package:afarma/page/afarmaPopular/completePurchase/ChangeAddressController.dart';
import 'package:afarma/page/afarmaPopular/profile/EditPersonalDetailsController.dart';
import 'package:afarma/page/afarmaPopular/profile/RegisterController.dart';
import 'package:afarma/page/afarmaPopular/purchase/PurchaseCompletedController.dart';
import 'package:afarma/repository/popularRepositories/AddressManager.dart';
import 'package:afarma/repository/popularRepositories/Cart.dart';
import 'package:afarma/service/DocumentScanner.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:get/get.dart';
import 'package:image_editor/image_editor.dart' as imgedit;
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

//https://maps.googleapis.com/maps/api/geocode/json?address=24220150&key=AIzaSyBVoOAFhxDgcGPT2jK7cKn1NXV2o7m77s8
// api key: AIzaSyBVoOAFhxDgcGPT2jK7cKn1NXV2o7m77s8

class CRMTextController {
  CRMTextController(
      {required this.crmController, required this.dateController});

  final TextEditingController crmController;
  final TextEditingController dateController;

  //DateTime selectedDate;

  String formattedDate() {
    List<String> components = dateController.text.split('/');
    String day = components[0];
    String month = components[1];
    String year = components[2];
    return year + month + day;
    //return dateController.text;
    /*
    String day = selectedDate.day >= 10 ? selectedDate.day.toString() : '0${selectedDate.day}';
    String month = selectedDate.month >= 10 ? selectedDate.month.toString() : '0${selectedDate.month}'; 
    String year = selectedDate.year.toString();
    return year + month + day;
    */
  }

  bool hasContent() {
    // return crmController.text.length > 0 && selectedDate != null;
    return crmController.text.length > 0 && dateController.text.length > 0;
  }
}

class CompletePurchaseController extends StatefulWidget {
  CompletePurchaseController({this.repeatOrder});

  Purchase? repeatOrder;

  @override
  _CompletePurchaseControllerState createState() =>
      _CompletePurchaseControllerState();
}

class _CompletePurchaseControllerState
    extends State<CompletePurchaseController> {
  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  MaskTextInputFormatter _dateFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  KeyboardUtils _keyboardUtils = KeyboardUtils();
  double bottomPadding = 0.0;

  bool? shouldFix;

  String? _purchaseID;

  TextStyle _defaultTitleTextStyle = TextStyle(
      color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w600);

  BoxDecoration _defaultBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2))
      ],
      color: Colors.white);

  List<File> _prescriptionImages = [];
  List<String?> _prescriptionIDs = [];

  List<File> _warrants = [];
  File? _warrantFile;
  File? _documentFile;
  List<String?> _warrantIDs = [];

  List<CRMTextController> _crmTextControllers = [];
  List<String> _crms = [];

  String? _observations;
  String? _indicationCode;

  @override
  void initState() {
    super.initState();
    shouldFixFlutter();
    _keyboardUtils.add(
        listener: KeyboardListener(
            willHideKeyboard: handleHideKeyboard,
            willShowKeyboard: (kHeight) => handleShowKeyboard(kHeight)));
    AddressManager().addListener(() {
      if (mounted) setState(() {});
    });
    print('PURCHASE === ${widget.repeatOrder}');
    if (widget.repeatOrder != null) {
      print('REPEAT ORDER === ${widget.repeatOrder!.items!.meds}');

      Cart().repeatOrder(widget.repeatOrder!);
      AddressManager()
          .selectAddress(widget.repeatOrder!.deliveryAddress, false);
    } else {
      print('DONT REPEAT ORDER === ${widget.repeatOrder}');
    }
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
          'Concluir pedido',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
          child: _mainBody(), padding: EdgeInsets.only(bottom: bottomPadding)),
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.0, width: MediaQuery.of(context).size.width),
          _productsList(),
          _buyerDetails(),
          _deliveryAddress(),
          _addPrescriptionPicture(),
          _prescriptionPictures(),
          _addCRM(),
          //_warrant(),
          _warrantPictures(),
          _observationsWidget(),
          // _indicationCodeWidget(),
          _inputButtons()
        ],
      ),
    );
  }

  Widget _productsList() {
    int index = 0;
    List<Widget> medicationWidgets = Cart().meds!.map((med) {
      int? amount = Cart().amounts![index];
      index++;
      return Padding(
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                med!.name!,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
                maxLines: 1,
              ),
              flex: 70,
            ),
            Expanded(
              child: Text(
                amount.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
                textAlign: TextAlign.right,
              ),
              flex: 20,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
        ),
        padding: EdgeInsets.only(top: 3, bottom: 3),
      );
    }).toList();

    return Padding(
        child: Container(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text('Lista de produtos', style: _defaultTitleTextStyle),
                      Spacer(),
                      Text('Quantidade', style: _defaultTitleTextStyle),
                    ],
                  )),
              SizedBox(height: 20.0),
              Column(children: medicationWidgets)
            ],
          ),
          decoration: _defaultBoxDecoration,
          width: MediaQuery.of(context).size.width - 40,
          padding: EdgeInsets.all(20),
        ),
        padding: EdgeInsets.only(bottom: 20.0));
  }

  Widget _buyerDetails() {
    return Padding(
      child: Container(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Dados do comprador', style: _defaultTitleTextStyle),
            ),
            SizedBox(height: 20.0),
            Padding(
              child: Text(
                'Nome: ${User.instance?.name ?? ''}',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
              ),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            ),
            Padding(
              child: Text(
                'CPF: ${User.instance != null ? CPFFormatter.format(User.instance!.cpf ?? '') : ''}',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
              ),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            ),
            Padding(
              child: Row(
                children: [
                  Text(
                    'Tel.: ${User.instance != null ? PhoneFormatter.format(User.instance!.cellphone ?? '') : ''}',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w300),
                  ),
                  Spacer(),
                  ButtonTheme(
                    child: RaisedButton(
                      child: AutoSizeText(
                        User.instance != null ? 'Trocar' : 'Cadastrar',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w300),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      color: Colors.grey,
                      onPressed: () => _addPersonalDetails(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    //height: 50,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        decoration: _defaultBoxDecoration,
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width - 40,
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget _deliveryAddress() {
    Address? selectedAddress = AddressManager().selectedAddress;
    return Padding(
        child: Container(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Endereço de entrega',
                  style: _defaultTitleTextStyle,
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                child: Row(
                  children: [
                    Text(
                      'Rua: ${selectedAddress?.street ?? ''}',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    Spacer(),
                    Text(
                      'Nº: ${selectedAddress?.number ?? ''}',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
              ),
              Padding(
                child: Text(
                  'Complemento: ${selectedAddress?.complement ?? ''}',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
                padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
              ),
              Padding(
                child: Row(children: [
                  Text(
                    'Bairro: ${selectedAddress?.neighborhood ?? ''}',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w300),
                  ),
                  Spacer(),
                  ButtonTheme(
                      child: RaisedButton(
                    child: AutoSizeText(
                      'Trocar Endereço',
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
                ]),
                padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          decoration: _defaultBoxDecoration,
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width - 40,
        ),
        padding: EdgeInsets.only(bottom: 20.0));
  }

  Widget _addPrescriptionPicture() {
    if (_prescriptionImages.length >= 1) return Container();
    return Padding(
      child: GestureDetector(
        child: Container(
          child: Column(
            children: [
              Text(
                //_prescriptionImages.length == 0 ? 'Tire foto da sua receita médica' : 'Adicionar outra receita médica',
                _prescriptionImages.length == 0
                    ? 'Escaneie sua receita médica'
                    : 'Adicionar outra receita médica',
                style: _defaultTitleTextStyle,
              ),
              SizedBox(height: 20.0),
              Icon(
                Icons.add_a_photo,
                size: 30,
              )
            ],
          ),
          decoration: _defaultBoxDecoration,
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width - 40,
        ),
        onTap: () => _getPrescriptionPicture(),
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget _prescriptionPictures() {
    return _prescriptionImages.length == 0
        ? Container()
        : Padding(
            child: Container(
              child: Column(
                children: [
                  Text('Receita', style: _defaultTitleTextStyle),
                  SizedBox(height: 20.0),
                  SingleChildScrollView(
                    child: Row(
                      children: _prescriptionImages.map((image) {
                        return GestureDetector(
                            child: Padding(
                              child: Image.file(
                                image,
                                height: 150,
                                width: 150,
                              ),
                              padding: EdgeInsets.only(right: 20.0),
                            ),
                            onTap: () => _imageOptions(image, false),
                            onLongPress: () => Get.to(
                                ViewImageWidget(image: FileImage(image)),
                                fullscreenDialog: true));
                      }).toList(),
                    ),
                    scrollDirection: Axis.horizontal,
                  )
                ],
              ),
              decoration: _defaultBoxDecoration,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
            ),
            padding: EdgeInsets.only(bottom: 20.0),
          );
  }

  Widget _addCRM() {
    List<Widget> textFields = [];
    //_crmTextControllers.clear();
    while (textFields.length <
        (_prescriptionImages.length > 3 ? 3 : _prescriptionImages.length)) {
      CRMTextController controller;
      TextEditingController crm;
      TextEditingController date;
      if (_crmTextControllers.length > textFields.length) {
        controller = _crmTextControllers[textFields.length];
        crm = controller.crmController;
        date = controller.dateController;
      } else {
        crm = TextEditingController();
        date = TextEditingController();
        controller =
            CRMTextController(crmController: crm, dateController: date);
        _crmTextControllers.add(controller);
      }
      textFields.add(Padding(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autocorrect: false,
                  autofocus: false,
                  controller: crm,
                  cursorColor: Color.fromRGBO(255, 49, 49, 1),
                  /* red */
                  decoration: InputDecoration(
                      fillColor: Color.fromRGBO(51, 146, 216, 1),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(255, 49, 49, 1) /* red */)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.6))),
                      hintText: 'CRM do médico',
                      hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      hintMaxLines: crm.text != null ? 1 : 2),
                  enableSuggestions: false,
                  expands: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9.-]*$')),
                  ],
                  keyboardType: TextInputType.datetime,
                  maxLines: 1,
                  obscureText: false,
                  onSubmitted: (crm) {
                    _crms[textFields.length] = crm;
                  },
                  textCapitalization: TextCapitalization.none,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                flex: 45,
              ),
              Spacer(flex: 1),
              Expanded(
                child: TextField(
                  autocorrect: false,
                  autofocus: false,
                  controller: date,
                  cursorColor: Color.fromRGBO(255, 49, 49, 1),
                  /* red */
                  decoration: InputDecoration(
                      fillColor: Color.fromRGBO(51, 146, 216, 1),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(255, 49, 49, 1) /* red */)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.6))),
                      hintText: 'Data da receita',
                      hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      hintMaxLines: 2),
                  inputFormatters: [_dateFormatter],
                  enableSuggestions: false,
                  keyboardType: TextInputType.datetime,
                  expands: false,
                  maxLines: 1,
                  obscureText: false,
                  textCapitalization: TextCapitalization.none,
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                flex: 45,
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: 15.0)));
    }
    return _prescriptionImages.length == 0
        ? Container()
        : Padding(
            child: Container(
              child: Column(
                children: textFields,
              ),
              decoration: _defaultBoxDecoration,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
            ),
            padding: EdgeInsets.only(bottom: 20.0),
          );
  }

  /*
  Expanded(
                child: GestureDetector(
                  child: AbsorbPointer(
                    child: TextField(  
                      autocorrect: false,
                      autofocus: false,    
                      controller: date,
                      cursorColor: Color.fromRGBO(255, 49, 49, 1), /* red */
                      decoration: InputDecoration(
                        fillColor: Color.fromRGBO(51, 146, 216, 1),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(255, 49, 49, 1) /* red */) 
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.6))
                        ),
                        hintText: 'Data da receita',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                        ),
                        hintMaxLines: 2
                      ),
                      enableSuggestions: false,
                      expands: false,
                      maxLines: 1,
                      obscureText: false,
                      textCapitalization: TextCapitalization.none,
                      style: TextStyle(
                        color: Colors.black
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () => _addDate(controller),
                ),
                flex: 45,
              ),

  */

  Widget _inputButtons() {
    return Padding(
      child: Row(
        children: [
          Expanded(
            child: ButtonTheme(
              child: RaisedButton(
                child: AutoSizeText(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                color: Colors.blue,
                onPressed: () => _cancel(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              height: 50,
            ),
            flex: 35,
          ),
          Spacer(flex: 5),
          Expanded(
            child: ButtonTheme(
              child: RaisedButton(
                child: AutoSizeText(
                  'Enviar pedido',
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                color: Colors.red,
                onPressed: () => _verifyPurchase(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              height: 50,
            ),
            flex: 60,
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
    );
  }

  Widget _warrant() {
    return _warrants != null && _warrants.length != 0
        ? SizedBox()
        : Padding(
            child: InkWell(
              child: Center(
                child: RichText(
                  text: TextSpan(
                      text: 'Possui procuração? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'Adicione aqui',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w700))
                      ]),
                ),
              ),
              onTap: () => _getWarrantPictures(
                  _warrantFile != null ? 'photo' : 'blackAndWhite'),
            ),
            padding: EdgeInsets.only(bottom: 20.0));
  }

  Widget _warrantPictures() {
    return _warrants != null && _warrants.length != 0
        ? Padding(
            child: Container(
              child: Column(
                children: [
                  Text(
                    'Anexe procuração e documento',
                    style: _defaultTitleTextStyle,
                  ),
                  SizedBox(height: 20.0),
                  SingleChildScrollView(
                    child: Row(
                        children: _warrants.map((warrant) {
                      return GestureDetector(
                        child: Padding(
                          child: Image.file(warrant, height: 150, width: 150),
                          padding: EdgeInsets.only(right: 20.0),
                        ),
                        onTap: () => _imageOptions(warrant, true),
                        onLongPress: () => Get.to(
                            ViewImageWidget(image: FileImage(warrant)),
                            fullscreenDialog: true),
                      );
                    }).toList()),
                    scrollDirection: Axis.horizontal,
                  ),
                  _warrants.length == 1
                      ? Column(
                          children: [
                            SizedBox(height: 20.0),
                            InkWell(
                              child: Center(
                                child: Text(
                                    'Escanear ${_warrantFile != null ? 'documento do procurador' : 'procuração'}',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700)),
                              ),
                              onTap: () => _getWarrantPictures(
                                  _warrantFile != null
                                      ? 'photo'
                                      : 'blackAndWhite'),
                            )
                          ],
                        )
                      : Container()
                ],
              ),
              decoration: _defaultBoxDecoration,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
            ),
            padding: EdgeInsets.only(bottom: 20.0),
          )
        : SizedBox();
  }

  Widget _observationsWidget() {
    return Padding(
        child: Container(
            child: Column(children: [
              Text('Observações (opcional)', style: _defaultTitleTextStyle),
              SizedBox(height: 7.5),
              TextField(
                autocorrect: false,
                autofocus: false,
                cursorColor: Color.fromRGBO(255, 49, 49, 1),
                /* red */
                controller: TextEditingController(text: _observations),
                decoration: InputDecoration(
                  fillColor: Color.fromRGBO(51, 146, 216, 1),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(255, 49, 49, 1) /* red */)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.6))),
                  hintText: 'Insira aqui suas observações',
                  hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                enableSuggestions: true,
                expands: false,
                keyboardType: TextInputType.text,
                maxLines: null,
                obscureText: false,
                onChanged: (obs) {
                  _observations = obs;
                },
                onSubmitted: (obs) {
                  _observations = obs;
                },
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ]),
            decoration: _defaultBoxDecoration,
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40),
        padding: EdgeInsets.only(bottom: 20.0));
  }

  Widget _indicationCodeWidget() {
    return Padding(
        child: Container(
            child: Column(children: [
              Text('Possui um código de indicação?',
                  style: _defaultTitleTextStyle),
              SizedBox(height: 7.5),
              TextField(
                autocorrect: false,
                autofocus: false,
                cursorColor: Color.fromRGBO(255, 49, 49, 1),
                /* red */
                controller: TextEditingController(text: _indicationCode),
                decoration: InputDecoration(
                  fillColor: Color.fromRGBO(51, 146, 216, 1),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(255, 49, 49, 1) /* red */)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.6))),
                  hintText: 'Insira aqui o código ou deixe em branco',
                  hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                enableSuggestions: true,
                expands: false,
                keyboardType: TextInputType.text,
                maxLines: null,
                obscureText: false,
                onChanged: (indCode) {
                  _indicationCode = indCode;
                },
                onSubmitted: (indCode) {
                  _indicationCode = indCode;
                },
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ]),
            decoration: _defaultBoxDecoration,
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width - 40),
        padding: EdgeInsets.only(bottom: 20.0));
  }

  /*
  void _getWarrantPictures() async {
    List<File> pickedImages = [];
    bool isSimulator;
    if (Platform.isIOS) {
      IosDeviceInfo deviceInfo = CurrentDeviceInfo().deviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo deviceInfo = CurrentDeviceInfo().deviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    }
    List<Asset> images = await MultiImagePicker.pickImages(maxImages: 2, enableCamera: !isSimulator);
    for (Asset image in images) {
      var path = await FlutterAbsolutePath.getAbsolutePath(image.identifier);
      pickedImages.add(File(path));
    }
    _warrants = pickedImages ?? [];
    if (mounted) setState(() {});
  }
  */

  void _getWarrantPictures(String typeScan) async {
    bool isSimulator;
    if (Platform.isIOS) {
      IosDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as IosDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as AndroidDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    }
    File pickedWarrant = await DocumentScanner.getDocument(typeScan, context);
    if (_warrants == null) _warrants = [];
    if (pickedWarrant != null) _warrants.add(pickedWarrant);
    if (_warrantFile == null) {
      _warrantFile = pickedWarrant;
    } else {
      _documentFile = pickedWarrant;
    }
    if (mounted) setState(() {});
  }

  void _getPrescriptionPicture() async {
    if (_prescriptionImages.length >= 1) {
      _alert('Você já inseriu o número máximo de receitas', null);
      return;
    }
    final a = await showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            content: Text(
                'Sua receita possui seu endereço? Favor preencher à caneta para não ter o pedido rejeitado.'),
          );
        },
        barrierDismissible: false,
        context: context);
    File pickedImage;
    bool isSimulator;
    if (Platform.isIOS) {
      IosDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as IosDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo deviceInfo =
          CurrentDeviceInfo().deviceInfo as AndroidDeviceInfo;
      isSimulator = !deviceInfo.isPhysicalDevice;
    }
    pickedImage = await DocumentScanner.getDocument('blackAndWhite', context);

    _addPicture(pickedImage);
    // .then((result) {
    //   String enhancedUrl = result['scans'][0]['enhancedUrl'];

    //   print(enhancedUrl);
    // });

    /*
    showDialog(
      builder: (context) {
        return AlertDialog(
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                pickedImage = await DocumentScanner.getDocument(isSimulator ? imgpick.ImageSource.gallery : imgpick.ImageSource.camera);
                _addPicture(pickedImage);
              }
            ),
            FlatButton(
              child: Text('Escolher na galeria'),
              onPressed: () async {
                Navigator.pop(context);
                pickedImage = await DocumentScanner.getDocument(imgpick.ImageSource.gallery);
                _addPicture(pickedImage);
              }
            )
          ],
          content: Text('Tirar foto ou escolher na galeria? Lembre-se de selecionar ou tirar uma foto na horizontal.'),
        );
      },
      context: context
    );
    */
  }

  void _addPicture(File pickedImage) {
    if (pickedImage == null) return;
    if (_prescriptionImages == null) _prescriptionImages = [];
    /*
    if (AddressManager().selectedAddress != null) {
      _prescriptionImages.add(await _addWatermark(toAdd));
    } else {
      _prescriptionImages.add(toAdd);
    }
    */
    _prescriptionImages.add(pickedImage);
    if (mounted) setState(() {});
  }

  void _imageOptions(File img, bool isWarrant) async {
    final a = await showModalBottomSheet(
        builder: (context) => Container(
              child: Column(
                children: [
                  GestureDetector(
                    child: Image.file(
                      img,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    children: [
                      ButtonTheme(
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
                          onPressed: () {
                            int index =
                                (isWarrant ? _warrants : _prescriptionImages)
                                    .indexOf(img);
                            if (index != -1) {
                              if (isWarrant) {
                                _warrants.removeAt(index);
                              } else {
                                if (_prescriptionIDs.length > 0 &&
                                    _prescriptionIDs.length ==
                                        _prescriptionImages.length) {
                                  _prescriptionIDs.removeAt(index);
                                }
                                _prescriptionImages.removeAt(index);
                              }
                              (isWarrant ? _warrants : _prescriptionImages)
                                  .removeAt(index);
                              if (!isWarrant) {
                                if (_crms.length - 1 >= index)
                                  _crms.removeAt(index);
                                if (_crmTextControllers.length - 1 >= index)
                                  _crmTextControllers.removeAt(index);
                              } else {
                                if (_warrantFile == img) {
                                  _warrantFile = null;
                                } else {
                                  _documentFile = null;
                                }
                              }
                            }
                            Navigator.pop(context);
                            setState(() {});
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        height: 50,
                      ),
                      SizedBox(height: 20.0),
                      ButtonTheme(
                        child: RaisedButton(
                          child: Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Ver imagem',
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
                          onPressed: () {
                            Navigator.pop(context);
                            Get.to(ViewImageWidget(image: FileImage(img)),
                                fullscreenDialog: true);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        height: 50,
                      ),
                    ].reversed.toList(),
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

  void _addPersonalDetails() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
            //builder: (context) => PersonalDetailsController()
            builder: (context) => User.instance != null
                ? EditPersonalDetailsController()
                : RegisterController(isFromPurchase: true),
            settings: RouteSettings(name: 'PersonalDetailsRoute')));
    if (mounted) setState(() {});
  }

  void _changeAddress() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeAddressController(),
        ));
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _verifyPurchase() async {
    if (_warrants == null || _warrants.length < 2) {
      bool? hasWarrant;
      await showDialog(
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    hasWarrant = true;
                  },
                ),
                FlatButton(
                  child: Text('Não'),
                  onPressed: () {
                    Navigator.pop(context);
                    hasWarrant = false;
                  },
                ),
              ].reversed.toList(),
              content: Text(
                'Possui procuração?\nSe sim adicione-a',
                textAlign: TextAlign.center,
              ),
            );
          },
          context: context);
      if (hasWarrant != null && hasWarrant == true) {
        _getWarrantPictures(_warrantFile != null ? 'photo' : 'blackAndWhite');
        return;
      }
    }
    List<bool?> checks = [
      await _checkPrice(),
      await _checkTime(),
      await _checkRestriction()
    ];
    if (!checks.contains(false)) {
      if (_checkUser() == false) return;
      if (_checkAddress() == false) return;
      if (_checkPrescriptions() == false) return;
      if (_warrants != null && _warrants.length != 0) {
        _sendWarrants().then((_) => _sendPrescriptions());
      } else {
        _sendPrescriptions();
      }
    }
  }

  Future<bool?> _checkPrice() async {
    if (Cart().meds!.indexWhere((element) => element!.needsPayment()) != -1) {
      bool? ret;
      await showDialog(
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    ret = true;
                  },
                ),
              ],
              content: Text(
                  'Este pedido terá o preço total de ${MoneyFormatter.format(Cart().paymentAmount())}, que deverá ser pago ao entregador.'),
            );
          },
          context: context);
      return ret;
    } else {
      return true;
    }
  }

  Future<bool?> _checkTime() async {
    DateTime now = DateTime.now();
    if (now.hour >= 20 || (now.weekday == DateTime.sunday && now.hour >= 18)) {
      bool? ret;
      await showDialog(
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    ret = true;
                  },
                ),
                FlatButton(
                  child: Text('Não'),
                  onPressed: () {
                    Navigator.pop(context);
                    ret = false;
                  },
                ),
              ].reversed.toList(),
              content:
                  Text('Seu pedido só será entregue amanhã. Deseja continuar?'),
            );
          },
          context: context);
      return ret;
    } else {
      return true;
    }
  }

  Future<bool> _checkRestriction() async {
    // if (Cart().meds.length == 1 && Cart().meds.first.restricted) {
    //   bool ret;
    //   await showDialog(
    //     barrierDismissible: false,
    //     builder: (context) {
    //       return AlertDialog(
    //         actions: [
    //           FlatButton(
    //             child: Text('Sim'),
    //             onPressed: () {
    //               Navigator.pop(context);
    //               ret = true;
    //             },
    //           ),
    //           FlatButton(
    //             child: Text('Não'),
    //             onPressed: () {
    //               Navigator.pop(context);
    //               ret = false;
    //             },
    //           ),
    //         ].reversed.toList(),
    //         content: Text('Este pedido terá um custo de entrega de R\$2,00, que deverá ser pago ao entregador. Deseja enviar o pedido?'),
    //       );
    //     },
    //     context: context
    //   );
    //   return ret;
    // } else {
    return true;
    // }
  }

  bool _checkUser() {
    bool ret = User.instance != null;
    if (ret == false) {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                    child: Text('Voltar'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: Text('Autenticar'),
                    onPressed: () {
                      Navigator.pop(context);
                      _addPersonalDetails();
                    })
              ],
              content: Text('Autentique-se no aplicativo e tente novamente'),
            );
          },
          context: context);
    }
    return ret;
  }

  bool _checkDocument() {
    bool ret = User.instance!.docIDs!.length > 0;
    if (ret == false) {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                    child: Text('Voltar'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: Text('Adicionar'),
                    onPressed: () {
                      Navigator.pop(context);
                      _addPersonalDetails();
                    })
              ],
              content: Text(
                  'Não existem documentos cadastrados para esse usuário, adicione-os.'),
            );
          },
          context: context);
    }
    return ret;
  }

  bool _checkAddress() {
    bool ret = AddressManager().selectedAddress != null;
    if (ret == false) {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                    child: Text('Voltar'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: Text('Adicionar'),
                    onPressed: () {
                      Navigator.pop(context);
                      _changeAddress();
                    })
              ],
              content: Text('Adicione um endereço e tente novamente'),
            );
          },
          context: context);
    }
    return ret;
  }

  bool _checkPrescriptions() {
    List<Widget> actions = [
      FlatButton(
          child: Text('Voltar'), onPressed: () => Navigator.pop(context)),
    ];
    if (_prescriptionImages.length == 0) {
      actions.add(FlatButton(
          child: Text('Adicionar'),
          onPressed: () {
            Navigator.pop(context);
            _getPrescriptionPicture();
          }));
    }
    bool ret = _prescriptionImages.length != 0 &&
        _crmTextControllers.every((element) => element.hasContent());
    if (ret == false) {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: actions,
              content: Text(
                  'Adicione ao menos uma receita, preencha o CEP, clique na lupa ao lado e tente novamente'),
            );
          },
          context: context);
    }
    return ret;
  }

  Future<void> _sendWarrants() async {
    _loadingAlert('Enviando procuração e documento...');
    for (File warrant in _warrants) {
      final resp = await _connector
          .uploadPicture('/api/v1/Procuracao/addProcuracao', warrant, {});
      if (resp.responseCode != -1 &&
          resp.responseCode! < 400 &&
          resp.returnBody!.trim() != '') {
        Map? parsedResp = jsonDecode(resp.returnBody!);
        if (parsedResp != null && parsedResp.containsKey('id')) {
          String? newID = parsedResp['id'] as String?;
          if (_warrantIDs.indexOf(newID) == -1) {
            _warrantIDs.add(newID);
          }
        } else {
          _alert('Ocorreu um erro ao enviar a procuração e/ou documento', -10);
        }
      } else {
        _alert('Ocorreu um erro ao enviar a procuração e/ou documento',
            resp.responseCode);
      }
    }
  }

  void _sendPurchase() async {
    _loadingAlert('Enviando pedido...');
    String prescriptions = '';
    if (_prescriptionIDs != null && _prescriptionIDs.length > 0) {
      prescriptions = ' "receitas": [';
      int index = 0;
      for (String? prescriptionID in _prescriptionIDs) {
        prescriptions += '${index > 0 ? ', ' : ''} { "id": "$prescriptionID" }';
        index++;
      }
      prescriptions += ' ],';
    }
    String warrants = '';
    if (_warrantIDs != null && _warrantIDs.length > 0) {
      warrants = '"procuracoes": [ ';
      int index = 0;
      for (String? warrantID in _warrantIDs) {
        warrants += '${index > 0 ? ', ' : ''} { "id": "$warrantID" }';
        index++;
      }
      warrants += ' ],';
    }
    var dateTime = DateTime.now();
    var dateTimeNow = dateTime.add(Duration(minutes: 180));
    String body =
        '{ "cesta": { "id": "${await Cart().getCartID()}" }, "enderecoEntrega": ${_purchaseAddress()},$prescriptions $warrants "dataPedido": "${dateTimeNow.toIso8601String()}", "codigoInd": "$_indicationCode", "origemPedido": "${Platform.isAndroid ? 'MOBILE_ANDROID' : 'MOBILE_IOS'}"';
    if (_indicationCode != null && _indicationCode!.trim() != '') {
      body += ', "codigoInd": "$_indicationCode"';
    }
    if (_observations != null && _observations!.trim() != '') {
      body += ', "observacao": "$_observations"';
    }
    body += ' }';
    final resp = await _connector.postContentWithBody('/api/v1/Pedido', body);
    Navigator.pop(context);
    if (resp.responseCode! < 400) {
      Map<String, dynamic> parsedResp = jsonDecode(resp.returnBody!);
      _purchaseID = parsedResp['id'];
      _cleanupAndExit();
    } else {
      List parsed = jsonDecode(resp.returnBody!);
      Map parsedList = parsed.first;
      if (parsedList.containsKey('error')) {
        _alert(parsedList['error'], resp.responseCode);
      } else {
        _alert(
            'Ocorreu um erro ao completar a compra, tente novamente mais tarde',
            resp.responseCode);
      }
    }
  }

  String _purchaseAddress() {
    return '{ "id": "${AddressManager().selectedAddress!.id}" }';
  }

  void _sendPrescriptions() async {
    if (_prescriptionIDs.length > 0 &&
        _prescriptionIDs.length == _prescriptionImages.length)
      return _sendPurchase();
    if (_prescriptionImages.length == 1) {
      CRMTextController crmController = _crmTextControllers.first;
      _loadingAlert('Enviando receita...');
      final resp = await _connector.uploadPicture(
          '/api/v1/Receita/addReceitaComData/${crmController.crmController.text}/${crmController.formattedDate()}-${User.instance!.cpf}/${crmController.formattedDate()}',
          _prescriptionImages.first, {});
      Navigator.pop(context);
      if (resp.responseCode == -1) {
        _alert('Ocorreu um erro ao enviar a foto da receita', null);
      } else if (resp.responseCode! < 400) {
        Map parsed = jsonDecode(resp.returnBody!);
        if (parsed.containsKey('id')) {
          _prescriptionIDs.add(parsed['id'] as String?);
        }
        _sendPurchase();
      } else {
        _alert(
            'Ocorreu um erro ao enviar a foto da receita', resp.responseCode);
      }
    } else {
      int index = 1;
      for (var prescription in _prescriptionImages) {
        CRMTextController crmController = _crmTextControllers[index - 1];
        _loadingAlert(
            'Enviando receita $index de ${_prescriptionImages.length}');
        final resp = await _connector.uploadPicture(
            '/api/v1/Receita/addReceitaComData/${crmController.crmController.text}/${crmController.formattedDate()}',
            prescription, {});
        Navigator.pop(context);
        if (resp.responseCode! < 400) {
          Map parsed = jsonDecode(resp.returnBody!);
          if (parsed.containsKey('id')) {
            _prescriptionIDs.add(parsed['id'] as String?);
          }
          index++;
        } else {
          _alert('Ocorreu um erro ao enviar a foto da ${index}ª receita',
              resp.responseCode);
          index = -1;
          return;
        }
      }
      if (index != -1) _sendPurchase();
    }
  }

  void _cleanupAndExit() {
    Purchase newPurchase = Purchase(
        id: _purchaseID,
        items: Cart().toPurchaseCart(),
        deliveryAddress: AddressManager().selectedAddress);
    Cart().clear();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PurchaseCompletedController(purchase: newPurchase),
          fullscreenDialog: true),
    );
  }

  Future<void> _alert(String? title, int? errCode) async {
    final a = await showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                  child: Text('OK'), onPressed: () => Navigator.pop(context))
            ],
            content:
                Text('$title ${errCode != null ? '(Erro: $errCode)' : ''}'),
          );
        },
        context: context);
    return;
  }

  void _loadingAlert(String title) {
    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(255, 49, 49, 1) /* red */),
                ),
                SizedBox(height: 20.0),
                Text(title)
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          );
        },
        context: context);
  }

  // Future<File?> _addWatermark(File picture) async {
  //   return picture;
  //   final text = imgedit.AddTextOption();
  //   text.addText(imgedit.EditorText(
  //       offset: Offset(0, 0),
  //       text: AddressManager().selectedAddress!.toWatermark(),
  //       fontSizePx: 15,
  //       textColor: Colors.red));
  //   imgedit.ImageEditorOption option = imgedit.ImageEditorOption();
  //   option.outputFormat = imgedit.OutputFormat.png(100);
  //   option.addOption(text);
  //   File? photoshoppedPicture =
  //       await imgedit.ImageEditor.editFileImageAndGetFile(
  //           file: picture, imageEditorOption: option);
  //   return photoshoppedPicture;
  // }

  void _addDate(CRMTextController controller) async {
    DateTime today = DateTime.now();
    final date = await (showDatePicker(
        context: context,
        initialDate: today,
        firstDate: today.subtract(Duration(days: 365)),
        lastDate: today) as FutureOr<DateTime>);
    //controller.selectedDate = date;
    controller.dateController.text = _formattedDate(date);
  }

  String _formattedDate(DateTime date) {
    String day = date.day >= 10 ? date.day.toString() : '0${date.day}';
    String month = date.month >= 10 ? date.month.toString() : '0${date.month}';
    String year = (date.year - 2000).toString();
    return '$day/$month/$year';
  }

  bool? shouldFixFlutter() {
    // basicamente fazemos o trabalho que o flutter devia fazer,
    // "levantar" a tela caso o textField não esteja visível nos
    // OSes que possuem o erro, mantendo o comportamento padrão nos
    // que não possuem.
    if (Platform.isAndroid) {
      Object? info = CurrentDeviceInfo().deviceInfo;
      if (info != null) {
        if (info is AndroidDeviceInfo) {
          // por enquanto, esse erro no teclado só ocorre em androids
          // com sdk < 30
          shouldFix = (info.version.sdkInt < 30);
        } else {
          print('what?');
        }
      } else {
        CurrentDeviceInfo()
            .getCurrentDeviceInfo()
            .then((_) => shouldFixFlutter());
      }
    } else {
      shouldFix = false;
    }
    return shouldFix;
  }

  void handleHideKeyboard() {
    bottomPadding = 0.0;
    if (shouldFix! && mounted) setState(() {});
  }

  void handleShowKeyboard(double kHeight) {
    if (shouldFix!) {
      bottomPadding = kHeight;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    DocumentScanner.cleanup();
    AddressManager().removeListener(() {});
    _keyboardUtils.removeAllKeyboardListeners();
    _keyboardUtils.dispose();
  }
}
