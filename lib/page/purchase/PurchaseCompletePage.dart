import 'dart:ui';
import 'package:afarma/Formatters/CPFFormatter.dart';
import 'package:afarma/Formatters/PhoneFormatter.dart';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/Purchase.dart';
import 'package:afarma/model/User.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

TextStyle _defaultTitleTextStyle =
    TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600);

TextStyle _defaultContentTextStyle =
    TextStyle(color: Colors.grey, fontWeight: FontWeight.w300);

class PurchaseCompletedPage extends StatefulWidget {
  PurchaseCompletedPage({
    required this.purchase,
    this.isFromPurchaseList = false,
  });

  final bool isFromPurchaseList;
  final Purchase purchase;

  @override
  _PurchaseCompletedPageState createState() => _PurchaseCompletedPageState();
}

class _PurchaseCompletedPageState extends State<PurchaseCompletedPage> {
  Purchase get _purchase => widget.purchase;

  @override
  void initState() {
    super.initState();
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
          'Pedido Concluído',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: _mainBody(),
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
      ),
    );
  }

  Widget _mainBody() {
    bool isOnDelivery = false;
    bool isRejected = false;
    bool isOutOfRange = false;

    if (_purchase != null) {
      isOnDelivery = _purchase.status == 'ENTREGUE';
      isRejected = _purchase.status == 'REJEITADO';
      isOutOfRange = _purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10.0),
          _pharmacyImageAndText(),
          _orderNumber(),
          isOnDelivery || isRejected || isOutOfRange
              ? (isRejected
                  ? _actionsComplete(_purchase)
                  : _actionsComplete(_purchase))
              : Container(),
          isRejected ? _rejectionReason(_purchase) : Container(),
          _productList(),
          _valorCompra(),
          _buyerDetails(),
          _deliveryAddress(),
          _obs(),
          //_drugStore(),
          // _mapView(),
          // _repeatButton(),
          _quitButton()
        ],
      ),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _pharmacyImageAndText() {
    return Column(
      children: [
        // SizedBox(height: 20.0),
        // Image.asset(
        //   'assets/images/logo-afarma-popular.png',
        //   width: MediaQuery.of(context).size.width - 40,
        //   height: 100,
        // ),
        // SizedBox(height: 10.0),
        // SizedBox(height: 10.0)
        // ,
        // Text(
        //     // Alteração feita por Elizier ${purchase.formattedStatus()}
        //   'O prazo de entrega é de até 1:00h.',
        //   style: TextStyle(
        //     color: AppColors.primary, /* red */
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500
        //   ),
        //   textAlign: TextAlign.center,
        // )
        // Text(
        //   '“TODOS OS ITENS DESTE PEDIDO SÃO ENTREGUES GRATUITAMENTE, POIS FAZEM PARTE DO PROGRAMA FARMÁCIA POPULAR”',
        //   style: TextStyle(
        //     color: AppColors.primary, /* red */
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500
        //   ),
        //   textAlign: TextAlign.center,
        // )
      ],
    );
  }

  Widget _orderNumber() {
    return Padding(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Pedido ${widget.purchase.formattedID()}',
          style: TextStyle(
              color: AppColors.primary,
              /* red */
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
      ),
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
    );
  }

  Widget _actionsComplete(Purchase purchase) {
    String rejectionReason =
        purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' '); // ?? '';
    bool isOnDelivery = purchase.status == 'ENTREGUE';
    bool isRejected = purchase.status == 'REJEITADO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width - 45,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isOnDelivery ? Colors.green : Colors.red[300]!,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isOutOfRange
                ? Row(children: [
                    Icon(Icons.info_outline,
                        color: (Colors.red[300]), size: 27),
                    SizedBox(width: 5),
                    Text(
                      'Pedido fora da área de atendimento.',
                      style: TextStyle(
                          color: Colors.red[300],
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    )
                  ])
                : (isRejected
                    ? Row(children: [
                        Icon(Icons.highlight_off,
                            color: (Colors.red[400]), size: 27),
                        SizedBox(width: 5),
                        Text(
                          'Pedido rejeitado pelo motivo abaixo:',
                          style: TextStyle(
                              color: Colors.red[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        )
                      ])
                    : Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: (Colors.green), size: 27),
                          SizedBox(width: 5),
                          Text(
                            'Pedido saiu para entrega.',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          )
                        ],
                      )),
          ),
        )
      ],
    );
  }

  Widget _ongoingActions(Purchase purchase) {
    // bool isDistributed = [
    //   'DISTRIBUIDO',
    //   'EM_ATENDIMENTO',
    //   'ENTREGUE',
    //   'REJEITADO',
    //   'FORA_DA_AREA_DE_ATENDIMENTO'
    // ].contains(purchase.status);
    // String rejectionReason =
    //     purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' '); // ?? '';
    // bool isAccepted =
    //     ['EM_ATENDIMENTO', 'ENTREGUE', 'REJEITADO'].contains(purchase.status);
    bool isInCall = purchase.status == 'EM_ATENDIMENTO';
    bool isOnDelivery = purchase.status == 'ENTREGUE';
    bool isRejected = purchase.status == 'REJEITADO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    // bool hasError = purchase.status == 'ABERTO';
    return Row(
      children: [
        isOutOfRange
            ? Expanded(
                child: Container(
                height: 4,
                color: Colors.red[200],
              ))
            : (isInCall
                ? Expanded(
                    child: Container(
                    height: 4,
                    color: Colors.green,
                  ))
                : (isOnDelivery
                    ? Expanded(
                        child: Container(
                        height: 4,
                        color: Colors.green,
                      ))
                    : (isRejected
                        ? Expanded(
                            child: Container(
                            height: 4,
                            color: Colors.red,
                          ))
                        : Expanded(
                            child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey[400]!),
                              backgroundColor: Colors.grey[300],
                              semanticsLabel: 'Linear progress indicator',
                            ),
                          )))),
        SizedBox(
          width: 6,
        ),
        isOutOfRange
            ? Expanded(
                child: Container(
                height: 4,
                color: Colors.red[200],
              ))
            : (isInCall
                ? Expanded(
                    child: LinearProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                      backgroundColor: Colors.grey[300],
                      semanticsLabel: 'Linear progress indicator',
                    ),
                  )
                : (isOnDelivery
                    ? Expanded(
                        child: Container(
                        height: 4,
                        color: Colors.green,
                      ))
                    : (isRejected
                        ? Expanded(
                            child: Container(
                            height: 4,
                            color: Colors.red,
                          ))
                        : Expanded(
                            child: Container(
                            height: 4,
                            color: Colors.grey[300],
                          ))))),
        SizedBox(
          width: 6,
        ),
      ],
    );
  }

  Widget _rejectionReason(Purchase purchase) {
    // debugPrint('rejectionReason: ${purchase.motivoRejeicao}');
    if (purchase.status == 'ENTREGUE' ||
        purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO') return Container();
    bool isRejected = purchase.status == 'REJEITADO';
    bool isDistributed = purchase.status == 'DISTRIBUIDO';
    // bool isEntregue = purchase.status == 'ENTREGUE';
    bool isInCall = purchase.status == 'EM_ATENDIMENTO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    String rejectionReason =
        purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' '); // ?? '';
    // String pharmacy = purchase.drugStore!.name; // ?? '';
    // List<String> phoneNums = purchase.drugStore!.phoneNumbers ?? [];

    if (purchase.status == 'ABERTO') {
      return Container();
    }

    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isRejected
              ? Container()
              : RichText(
                  text: TextSpan(
                      text: 'Pedido ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: isInCall
                                ? 'em análise'
                                : (purchase.status == 'ENTREGUE'
                                    ? 'saindo para entrega'
                                    : 'aguardando a farmácia aceitar o pedido.'),
                            style: TextStyle(
                                color: isRejected
                                    ? Colors.red
                                    : (isOutOfRange
                                        ? Colors.red[300]
                                        : Colors.green),
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
          isRejected || isDistributed ? Container() : SizedBox(height: 10.0),
          isRejected
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: 'Motivo da rejeição: \n',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(
                            text: '"$rejectionReason"',
                            style: TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                fontSize: 16))
                      ]),
                )
              : Container(),
        ],
      ),
      padding: EdgeInsets.only(
        top: 15.0,
        bottom: 10.0,
      ),
    );
  }

  Widget _productList() {
    int index = 0;
    List<Widget> medicationWidgets = _purchase.items!.meds.map((med) {
      int amount = _purchase.items!.amounts[index];
      index++;
      return Padding(
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                med.nome,
                style: _defaultContentTextStyle,
                maxLines: 1,
              ),
              flex: 80,
            ),
            Expanded(
              child: Text(
                amount.toString(),
                style: _defaultContentTextStyle,
                textAlign: TextAlign.right,
              ),
              flex: 0,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
        ),
        padding: EdgeInsets.only(top: 3, bottom: 3),
      );
    }).toList();

    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text('Lista de produtos', style: _defaultTitleTextStyle),
          ),
          SizedBox(height: 20.0),
          Column(children: medicationWidgets)
        ],
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _buyerDetails() {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text('Dados do comprador', style: _defaultTitleTextStyle),
          ),
          SizedBox(height: 20.0),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              child: Text('Nome: ${User.instance?.name ?? ''}',
                  style: _defaultContentTextStyle),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              child: Text('CPF: ${CPFFormatter.format(User.instance!.cpf!)}',
                  style: _defaultContentTextStyle),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              child: Text(
                  'Tel.: ${PhoneFormatter.format(User.instance!.cellphone)}',
                  style: _defaultContentTextStyle),
              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _valorCompra() {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'Forma de Pagamento',
              style: _defaultTitleTextStyle,
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            child: Row(
              children: [
                Text(
                  'Valor total do pedido: ${widget.purchase.getValorTotalDoPedidoString()}',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
          ),
          Padding(
            child: Row(
              children: [
                Text(
                  'Forma de pagamento: ${widget.purchase.getStringFormaPagamento()} ${widget.purchase.getTrocoString("(Troco ", ")")}',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _obs() {
    return widget.purchase.observacao == null ||
            widget.purchase.observacao == ''
        ? Container()
        : Container(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Observações',
                    style: _defaultTitleTextStyle,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  child: Row(
                    children: [
                      Text(
                        '${widget.purchase.observacao}',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            padding: EdgeInsets.all(20),
          );
  }

  Widget _deliveryAddress() {
    Address address = _purchase.deliveryAddress!;
    var street = address.street;
    var number = address.number;
    var complement = address.complement;
    var cep = address.cep;
    var neighborhood = address.neighborhood;

    if (street == null) {
      street = 'Não informado';
    }
    if (street.trim() == 'null') {
      street = 'Não informado';
    }

    if (number == null) {
      number = '';
    }
    if (number.trim() == 'null') {
      number = '';
    }

    if (complement == null) {
      complement = '';
    }
    if (complement.trim() == 'null') {
      complement = '';
    }

    if (cep == null) {
      cep = 'Não informado';
    }
    if (cep.trim() == 'null') {
      cep = 'Não informado';
    }

    if (neighborhood == null) {
      neighborhood = 'Não informado';
    }
    if (neighborhood.trim() == 'null') {
      neighborhood = 'Não informado';
    }

    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
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
                  'Rua: $street',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
                Spacer(),
                Text(
                  'Nº: $number',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
          ),
          Padding(
            child: Row(
              children: [
                Text(
                  'Complemento: $complement',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
                Spacer(),
                Text(
                  'CEP: $cep',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
          ),
          Padding(
            child: Row(
              children: [
                Text(
                  'Bairro: $neighborhood',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w300),
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _quitButton() {
    return Padding(
      child: IconButton(
        icon: Icon(Icons.cancel),
        color: AppColors.secondary,
        /* blue */
        iconSize: 60.0,
        onPressed: () => _quit(),
      ),
      padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
    );
  }

  void _quit() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (!widget.isFromPurchaseList) {
        Navigator.popUntil(context, ModalRoute.withName('ComparativeRoute'));
      }
      Navigator.pop(context, true);
    });
  }
}
