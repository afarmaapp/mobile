import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:afarma/Formatters/CPFFormatter.dart';
import 'package:afarma/Formatters/PhoneFormatter.dart';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/helper/Config.dart';
import 'package:afarma/helper/Connector.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/Cart.dart';
import 'package:afarma/model/Purchase.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/page/RegisterPage.dart';
import 'package:afarma/page/profile/ChangeAddressPage.dart';
import 'package:afarma/page/profile/EditPersonalDetailsPage.dart';
import 'package:afarma/repository/AddressRepository.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'PurchaseCompletePage.dart';

class CRMTextController {
  CRMTextController({
    required this.crmController,
    required this.dateController,
  });

  final TextEditingController crmController;
  final TextEditingController dateController;

  String formattedDate() {
    List<String> components = dateController.text.split('/');
    String day = components[0]; // ?? '01';
    String month = components[1]; // ?? '02';
    String year = components[2]; // ?? '1234';
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

class CompletePurchasePage extends StatefulWidget {
  CompletePurchasePage({this.repeatOrder});

  Purchase? repeatOrder;

  @override
  _CompletePurchasePageState createState() => _CompletePurchasePageState();
}

enum FormaPagamento { DINHEIRO, CARTAO_CREDITO, CARTAO_DEBITO, PIX }

class _CompletePurchasePageState extends State<CompletePurchasePage> {
  final Connector _connector =
      Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);
  // MaskTextInputFormatter _dateFormatter = MaskTextInputFormatter(
  //     mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  final GlobalKey<FormState> _formKey = GlobalKey();

  // KeyboardUtils _keyboardUtils = KeyboardUtils();
  double bottomPadding = 0.0;

  bool? shouldFix;

  String? _purchaseID;
  double? _valorTotalDoPedido;
  double? _troco;
  String? _observacao;

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

  String? _observations;
  String? _indicationCode;

  FormaPagamento? _formaPagamento = null;

  MoneyMaskedTextController trocoController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');

  MoneyMaskedTextController trocoProntoController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');

  MoneyMaskedTextController cartValueController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');

  MoneyMaskedTextController totalController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');

  @override
  void initState() {
    super.initState();
    AddressRepository().addListener(() {
      if (mounted) setState(() {});
    });
    // print('PURCHASE === ${widget.repeatOrder}');
    if (widget.repeatOrder != null) {
      // print('REPEAT ORDER === ${widget.repeatOrder!.items!.meds}');

      Cart().repeatOrder(widget.repeatOrder!);
      AddressRepository()
          .selectAddress(widget.repeatOrder!.deliveryAddress!, false);
    } else {
      // print('DONT REPEAT ORDER === ${widget.repeatOrder}');
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
        child: _mainBody(),
        padding: EdgeInsets.only(bottom: bottomPadding),
      ),
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
          _formaPagamentoWidget(),
          _observationsWidget(),
          _indicationCodeWidget(),
          _inputButtons(),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  Widget _productsList() {
    int index = 0;
    List<Widget> medicationWidgets = Cart().meds.map((med) {
      int amount = Cart().amounts[index];
      index++;
      return Padding(
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                med.nome,
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

    totalController.updateValue(Cart().lowerValue!);
    cartValueController.updateValue(Cart().cartValue!);

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
              Column(children: medicationWidgets),
              SizedBox(height: 10.0),
              Column(children: [
                Text(
                  "Melhor Preço aFarma",
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
                ),
                Cart().meds.length > 1
                    ? Text(
                        Cart().paymentAmountFormated(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationThickness: 2,
                        ),
                      )
                    : Container(),
                Text(
                  totalController.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ])
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
                    'Tel.: ${User.instance != null ? PhoneFormatter.format(User.instance!.cellphone) : ''}',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w300),
                  ),
                  Spacer(),
                  ButtonTheme(
                    child: RaisedButton(
                      child: AutoSizeText(
                        User.instance != null ? 'Alterar Dados' : 'Cadastrar',
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
    Address selectedAddress = Address(located: false);
    bool hasSelectedAddress = false;
    if (AddressRepository().selectedAddress != null) {
      selectedAddress = AddressRepository().selectedAddress!;
      hasSelectedAddress = true;
    }

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
              hasSelectedAddress
                  ? Padding(
                      child: Row(
                        children: [
                          Text(
                            'Rua: ${selectedAddress.street ?? ''}',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                          ),
                          Spacer(),
                          Text(
                            'Nº: ${selectedAddress.number ?? ''}',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                    )
                  : Container(),
              hasSelectedAddress
                  ? Padding(
                      child: Text(
                        'Complemento: ${selectedAddress.complement ?? ''}',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      ),
                      padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                    )
                  : Container(),
              Padding(
                child: Row(children: [
                  hasSelectedAddress
                      ? Text(
                          'Bairro: ${selectedAddress.neighborhood ?? ''}',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w300),
                        )
                      : Container(),
                  Spacer(),
                  ButtonTheme(
                      child: RaisedButton(
                    child: AutoSizeText(
                      hasSelectedAddress
                          ? 'Trocar Endereço'
                          : 'Criar ou Selecionar Endereço',
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

  Widget _formaPagamentoWidget() {
    String troquinho = trocoProntoController.text;

    return Padding(
      child: Container(
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Forma de Pagamento',
              style: _defaultTitleTextStyle,
            ),
          ),
          SizedBox(height: 7.5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RadioListTile<FormaPagamento>(
                contentPadding: EdgeInsets.all(0),
                selectedTileColor: AppColors.primary,
                activeColor: AppColors.primary,
                subtitle: Text(
                    "Pagamento em dinheiro (R\$)${_formaPagamento == FormaPagamento.DINHEIRO ? (trocoController.text == 'R\$ 0,00' ? '\n\nSem troco' : '\n\n$troquinho de troco.') : ''}"),
                title: const Text('Dinheiro'),
                value: FormaPagamento.DINHEIRO,
                groupValue: _formaPagamento,
                onChanged: (FormaPagamento? value) {
                  setState(() {
                    _formaPagamento = value;
                    checkIfDinheiro();
                  });
                },
              ),
              // (_formaPagamento == FormaPagamento.DINHEIRO
              //     ? (trocoController.text == 'R\$ 0,00'
              //         ? Text("Sem troco.")
              //         : Text("${trocoProntoController.text} de troco."))
              //     : Container()),
              RadioListTile<FormaPagamento>(
                contentPadding: EdgeInsets.all(0),
                selectedTileColor: AppColors.primary,
                activeColor: AppColors.primary,
                title: const Text('Cartão de Crédito'),
                subtitle: Text("Bandeiras VISA e Master"),
                value: FormaPagamento.CARTAO_CREDITO,
                groupValue: _formaPagamento,
                onChanged: (FormaPagamento? value) {
                  setState(() {
                    _formaPagamento = value;
                  });
                },
              ),
              RadioListTile<FormaPagamento>(
                contentPadding: EdgeInsets.all(0),
                selectedTileColor: AppColors.primary,
                activeColor: AppColors.primary,
                title: const Text('Cartão de Débito'),
                subtitle: Text("Aceitamos todos os bancos"),
                value: FormaPagamento.CARTAO_DEBITO,
                groupValue: _formaPagamento,
                onChanged: (FormaPagamento? value) {
                  setState(() {
                    _formaPagamento = value;
                  });
                },
              ),
              // RadioListTile<FormaPagamento>(
              //   contentPadding: EdgeInsets.all(0),
              //   selectedTileColor: AppColors.primary,
              //   activeColor: AppColors.primary,
              //   title: const Text('PIX'),
              //   subtitle: Text("Transferência sem custo"),
              //   value: FormaPagamento.PIX,
              //   groupValue: _formaPagamento,
              //   onChanged: (FormaPagamento? value) {
              //     setState(() {
              //       _formaPagamento = value;
              //     });
              //   },
              // ),
            ],
          )
        ]),
        decoration: _defaultBoxDecoration,
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width - 40,
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget _observationsWidget() {
    return Padding(
        child: Container(
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Observações (opcional)',
                    style: _defaultTitleTextStyle),
              ),
              SizedBox(height: 7.5),
              TextField(
                autocorrect: false,
                autofocus: false,
                cursorColor: AppColors.primary,
                /* red */
                controller: TextEditingController(text: _observations),
                decoration: InputDecoration(
                  fillColor: Color.fromRGBO(51, 146, 216, 1),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary /* red */)),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Possui um código de indicação?',
                    style: _defaultTitleTextStyle),
              ),
              SizedBox(height: 7.5),
              TextField(
                autocorrect: false,
                autofocus: false,
                cursorColor: AppColors.primary,
                /* red */
                controller: TextEditingController(text: _indicationCode),
                decoration: InputDecoration(
                  fillColor: Color.fromRGBO(51, 146, 216, 1),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary /* red */)),
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

  void checkIfDinheiro() {
    if (_formaPagamento == FormaPagamento.DINHEIRO) {
      showModalBottomSheet(
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Dinheiro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Você vai precisar de troco?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent,
                              border: Border.all(
                                  color: AppColors.primary, width: 1)),
                          child: Text(
                            'Não',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => {Navigator.pop(context), openTrocoModal()},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.primary,
                          ),
                          child: Text(
                            'Sim',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void openTrocoModal() {
    int numLines = 0;

    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 350,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Troco para quanto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Seu pedido deu ${totalController.text}.\nDigite quanto vai pagar em dinheiro para\nque leve-mos o seu troco.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Container(
                    width: numLines < 7 ? 100 : ((numLines - 7) * 20) + 100,
                    child: Form(
                      key: _formKey,
                      child: new TextFormField(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (trocoController.numberValue <
                              totalController.numberValue) {
                            return '';
                          }

                          return null;
                        },
                        maxLength: totalController.text.length + 1,
                        onChanged: (String value) {
                          setState(() {
                            numLines = trocoController.text.length;
                          });
                        },
                        controller: trocoController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  SizedBox(height: 35.0),
                  GestureDetector(
                    onTap: () => checkValorTroco(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary,
                      ),
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void checkValorTroco() {
    final bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      Navigator.pop(context);
      trocoProntoController.updateValue(
          totalController.numberValue - trocoController.numberValue);
    } else if (!isValid) {
      Future.delayed(Duration(seconds: 5), () => {Navigator.pop(context)});

      showGeneralDialog(
          context: context,
          barrierDismissible: true,
          transitionDuration: Duration(milliseconds: 500),
          barrierLabel: MaterialLocalizations.of(context).dialogLabel,
          barrierColor: Colors.transparent,
          pageBuilder: (context, _, __) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    height: 100,
                    color: Colors.grey[800],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 39,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'O valor informado não pode\nser menor que o valor do pedido!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        )
                      ],
                    ),
                  ),
                ]);
          });
    }
  }

  void _addPersonalDetails() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
            //builder: (context) => PersonalDetailsController()
            builder: (context) => User.instance != null
                ? EditPersonalDetailsPage()
                : RegisterPage(isFromPurchase: true),
            settings: RouteSettings(name: 'PersonalDetailsRoute')));
    if (mounted) setState(() {});
  }

  void _changeAddress() async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeAddressPage(),
        ));
  }

  void _cancel() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<bool> _checkFormaPagamento() async {
    if (_formaPagamento == null) {
      showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: [
                  FlatButton(
                    child: Text('Entendi!'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                content: Text('É necessário escolher uma forma de pagamento.'),
              ),
            );
          },
          context: context);

      return false;
    }

    if (_formaPagamento == FormaPagamento.DINHEIRO) {
      double val = trocoController.numberValue;
      if (val == 0.0) {
        bool result = (await showDialog<bool>(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: [
                  FlatButton(
                      child: Text('Vou revisar'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      }),
                  FlatButton(
                    child: Text('É isso mesmo, não preciso de troco!'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
                content: Text('É necessário escolher uma forma de pagamento.'),
              ),
            );
          },
          context: context,
        ))!;

        return result;
      }
    }

    return true;
  }

  bool _checkAddress() {
    bool ret = AddressRepository().selectedAddress != null;
    if (ret == false) {
      showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
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
              ),
            );
          },
          context: context);
    }
    return ret;
  }

  void _verifyPurchase() async {
    bool cont = false;
    List<bool> checks = [
      await _checkTroco(cont),
      await _checkTime(cont),
    ];
    if (!checks.contains(false)) {
      if (_checkUser() == false) return;
      if (_checkAddress() == false) return;
      if (await _checkFormaPagamento() == false) return;

      // Envia!
      _sendPurchase();
    }
  }

  Future<bool> _checkTroco(cont) async {
    bool ret = false;
    if (trocoController.text != 'R\$ 0,00' &&
        trocoProntoController.text == 'R\$ 0,00') {
      await showDialog(
          barrierDismissible: false,
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      ret = false;
                      cont = false;
                    },
                  ),
                ],
                content: Text(
                    //'Este pedido terá o preço total de ${MoneyFormatter.format(Cart().paymentAmount())}, que deverá ser pago ao entregador.'),
                    'O valor informado para o troco não pode ser menor do que o valor do pedido!'),
              ),
            );
          },
          context: context);
    } else {
      ret = true;
      cont = true;
    }
    if (cont == true) {
      await showDialog(
          barrierDismissible: false,
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                actions: [
                  FlatButton(
                    child: Text('CANCELAR'),
                    onPressed: () {
                      Navigator.pop(context);
                      ret = false;
                      cont = false;
                    },
                  ),
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      ret = true;
                      cont = true;
                    },
                  ),
                ],
                content: Text(
                    //'Este pedido terá o preço total de ${MoneyFormatter.format(Cart().paymentAmount())}, que deverá ser pago ao entregador.'),
                    'Este pedido terá o preço total de ${totalController.text}'),
              ),
            );
          },
          context: context);
    }
    return ret;
  }

  Future<bool> _checkTime(cont) async {
    if (cont == true) {
      DateTime now = DateTime.now();
      if (now.hour >= 20 ||
          (now.weekday == DateTime.sunday && now.hour >= 18)) {
        bool ret = false;
        await showDialog(
            barrierDismissible: false,
            builder: (context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
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
                  content: Text(
                      'Seu pedido só será entregue amanhã. Deseja continuar?'),
                ),
              );
            },
            context: context);
        return ret;
      } else {
        return true;
      }
    }

    return true;
  }

  bool _checkUser() {
    bool ret = User.instance != null;
    if (ret == false) {
      showDialog(
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
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
              ),
            );
          },
          context: context);
    }
    return ret;
  }

  void _sendPurchase() async {
    _loadingAlert('Enviando pedido...');

    var dateTime = DateTime.now();
    var dateTimeNow = dateTime.add(Duration(minutes: 180));
    String body =
        '{ "cesta": { "id": "${await Cart().getCartID()}" }, "enderecoEntrega": ${_purchaseAddress()}, "dataPedido": "${dateTimeNow.toIso8601String()}", "codigoInd": "$_indicationCode", "origemPedido": "${Platform.isAndroid ? 'MOBILE_ANDROID' : 'MOBILE_IOS'}"';
    if (_indicationCode != null && _indicationCode!.trim() != '') {
      body += ', "codigoInd": "$_indicationCode"';
    }
    if (_observations != null && _observations!.trim() != '') {
      body += ', "observacao": "$_observations"';
    }
    if (_formaPagamento != null) {
      final f = _formaPagamento.toString().replaceAll("FormaPagamento.", "");
      body += ', "formaPagamento": "$f"';
    }
    if (_formaPagamento == FormaPagamento.DINHEIRO) {
      final troco = trocoController.numberValue - totalController.numberValue;
      body += ', "troco": $troco';
    }
    body += ' }';
    final resp = await _connector.postContentWithBody('/api/v1/Pedido', body);
    Navigator.pop(context);
    if (resp.responseCode! < 400) {
      Map<String, dynamic> parsedResp = jsonDecode(resp.returnBody!);
      _purchaseID = parsedResp['id'];
      _valorTotalDoPedido = parsedResp['valorTotalDoPedido'];
      _formaPagamento = FormaPagamento.values.firstWhere((e) =>
          e.toString() == 'FormaPagamento.' + parsedResp['formaPagamento']);
      _troco = parsedResp['troco'];
      _observacao = parsedResp['observacao'];
      _cleanupAndExit();
    } else {
      List parsed = jsonDecode(resp.returnBody!);
      Map parsedList = parsed.first;
      if (parsedList.containsKey('error')) {
        _alert(parsedList['error'], resp.responseCode!);
      } else {
        _alert(
            'Ocorreu um erro ao completar a compra, tente novamente mais tarde',
            resp.responseCode!);
      }
    }
  }

  String _purchaseAddress() {
    return '{ "id": "${AddressRepository().selectedAddress!.id}" }';
  }

  void _cleanupAndExit() {
    Purchase newPurchase = Purchase(
        id: _purchaseID,
        valorTotalDoPedido: _valorTotalDoPedido,
        formaPagamento: _formaPagamento,
        troco: _troco,
        observacao: _observacao,
        items: Cart().toPurchaseCart(),
        deliveryAddress: AddressRepository().selectedAddress);
    Cart().clear();

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PurchaseCompletedPage(purchase: newPurchase),
          fullscreenDialog: true),
    );
  }

  Future<void> _alert(String title, int errCode) async {
    final a = await showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                    child: Text('OK'), onPressed: () => Navigator.pop(context))
              ],
              content:
                  Text('$title ${errCode != null ? '(Erro: $errCode)' : ''}'),
            ),
          );
        },
        context: context);
    return;
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
                      AppColors.primary /* red */,
                    ),
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

  void _addDate(CRMTextController controller) async {
    DateTime today = DateTime.now();
    final date = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: today.subtract(Duration(days: 365)),
        lastDate: today);
    //controller.selectedDate = date;
    controller.dateController.text = _formattedDate(date!);
  }

  String _formattedDate(DateTime date) {
    String day = date.day >= 10 ? date.day.toString() : '0${date.day}';
    String month = date.month >= 10 ? date.month.toString() : '0${date.month}';
    String year = (date.year - 2000).toString();
    return '$day/$month/$year';
  }

  @override
  void dispose() {
    super.dispose();
    AddressRepository().removeListener(() {});
  }
}
