import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/Purchase.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/page/profile/ProfilePage.dart';
import 'package:afarma/page/purchase/PurchaseCompletePage.dart';
import 'package:afarma/repository/PurchaseRepository.dart';
import 'package:afarma/service/LoggedInNotifierService.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextStyle _defaultTitleTextStyle = const TextStyle(
    color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600);

class PurchasesPage extends StatefulWidget {
  PurchasesPage({
    required this.scrollController,
    required this.pageController,
    this.tabIndex,
    required this.onShowTabBar,
  });

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex? tabIndex;
  final VoidCallback onShowTabBar;

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  List<Purchase> get _purchases => PurchaseRepository().purchases;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    PurchaseRepository().fetchPurchases().then((value) {
      this.loading = false;
    });

    PurchaseRepository().addListener(() {
      if (mounted) setState(() {});
    });

    // Listener LOGGED IN
    LoggedInNotifierService().addListener(() {
      if (mounted) setState(() {});
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Pedidos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          splashRadius: 1,
          padding: EdgeInsets.all(10),
          iconSize: 30,
          icon:
              Icon(User.instance == null ? Icons.person_outline : Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ).then((value) {
              PurchaseRepository().fetchPurchases();
              setState(() {});
            });
          },
        ),
      ),
      body: RefreshIndicator(
        child: Container(child: _mainBody()),
        onRefresh: () => _refreshData(),
      ),
    );
  }

  Future<void> _refreshData() async {
    this.loading = true;
    PurchaseRepository().refreshPurchases();
  }

  Widget _mainBody() {
    //RenderBox bottomBarRender = floatingBarKey.currentContext.findRenderObject();
    //double size = bottomBarRender.size.height ?? 0;
    double size = 150;
    bool isLogged = User.instance != null;
    // print('User === ${User.instance}');

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      child: isLogged
          ? Column(
              children: [
                _ongoingPurchase(),
                _oldPurchases(),
                SizedBox(height: size)
              ],
            )
          : Container(
              padding: EdgeInsets.only(top: 100, left: 30, right: 30),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Ops!\n',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                    children: [
                      TextSpan(
                        text: 'Fa??a login para ver seus pedidos.',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _ongoingPurchase() {
    Purchase? recentPurchase = PurchaseRepository().purchases.length > 0
        ? PurchaseRepository().purchases.first
        : null;

    bool isOnDelivery = false;
    bool isRejected = false;
    bool isOutOfRange = false;

    if (recentPurchase != null) {
      isOnDelivery = recentPurchase.status == 'ENTREGUE';
      isRejected = recentPurchase.status == 'REJEITADO';
      isOutOfRange = recentPurchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    }

    // if (recentPurchase == null || ['ENTREGUE', 'REJEITADO'].contains(recentPurchase.status)) return Container();
    if (recentPurchase == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 180.0),
        child: Center(
            child: Column(
          children: [
            // CircularProgressIndicator(),
            // SizedBox(
            //   height: 5,
            // ),
            !loading
                ? Text(
                    'Nenhum pedido realizado ainda!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary /* red */),
                  ),
          ],
        )),
      );
    }
    return Column(
      children: [
        Padding(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              //ALTERA????O FEITA POR ELIZIER
              //'Pedido em andamento',
              'Pedido ${recentPurchase.formattedStatus()}',
              style: _defaultTitleTextStyle,
            ),
          ),
          padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
        ),
        Container(
          child: Column(
            children: [
              Padding(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pedido ${recentPurchase.formattedID()}',
                    style: TextStyle(
                        color: AppColors.primary,
                        /* red */
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              isOutOfRange || isRejected || isOnDelivery
                  ? _actionsComplete(recentPurchase)
                  : _ongoingActions(recentPurchase),
              _rejectionReason(recentPurchase),
              _ongoingDeliveryAddress(recentPurchase)
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.0,
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0, 2),
                  spreadRadius: 1.0,
                ),
              ],
              color: Colors.white),
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width - 40,
        )
      ],
    );
  }

  // Widget _ongoingActions(Purchase purchase) {
  //   bool isDistributed = [
  //     'DISTRIBUIDO',
  //     'EM_ATENDIMENTO',
  //     'ENTREGUE',
  //     'REJEITADO',
  //     'FORA_DA_AREA_DE_ATENDIMENTO'
  //   ].contains(purchase.status);
  //   String rejectionReason =
  //       purchase.motivoRejeicao.replaceAll(new RegExp(r'\+'), ' ') ?? '';
  //   bool isAccepted =
  //       ['EM_ATENDIMENTO', 'ENTREGUE', 'REJEITADO'].contains(purchase.status);
  //   bool isOnDelivery = purchase.status == 'ENTREGUE';
  //   bool isRejected = purchase.status == 'REJEITADO';
  //   bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
  //   bool hasError = purchase.status == 'ABERTO';
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Column(
  //           children: [
  //             Icon(Icons.archive,
  //                 color: (isDistributed ? Colors.green : Colors.grey),
  //                 size: 35),
  //             SizedBox(height: 10.0),
  //             Text('Pedido distribu??do',
  //                 style: TextStyle(fontSize: 10),
  //                 maxLines: 2,
  //                 textAlign: TextAlign.center)
  //           ],
  //         ),
  //         flex: 20,
  //       ),
  //       Expanded(
  //         child: Column(
  //           children: [
  //             Divider(
  //               color: (isAccepted ? Colors.green : Colors.grey),
  //               thickness: 1.3,
  //             ),
  //             SizedBox(height: 30.0)
  //           ],
  //         ),
  //         flex: 20,
  //       ),
  //       (isOutOfRange)
  //           ? Expanded(
  //               child: Column(
  //                 children: [
  //                   Icon(Icons.cancel, color: Colors.red, size: 35),
  //                   SizedBox(height: 10.0),
  //                   Text('Pedido rejeitado',
  //                       style: TextStyle(fontSize: 10),
  //                       maxLines: 2,
  //                       textAlign: TextAlign.center)
  //                 ],
  //               ),
  //               flex: 20,
  //             )
  //           : Expanded(
  //               child: Column(
  //                 children: [
  //                   Icon(Icons.receipt,
  //                       color: (isAccepted ? Colors.green : Colors.grey),
  //                       size: 35),
  //                   SizedBox(height: 10.0),
  //                   Text(
  //                     'Pedido em an??lise',
  //                     style: TextStyle(fontSize: 10),
  //                     maxLines: 2,
  //                     textAlign: TextAlign.center,
  //                   )
  //                 ],
  //               ),
  //               flex: 20,
  //             ),
  //       Expanded(
  //         child: Column(
  //           children: [
  //             Divider(
  //               color: (isRejected
  //                   ? Colors.red
  //                   : (isOnDelivery ? Colors.green : Colors.grey)),
  //               thickness: 1.3,
  //             ),
  //             SizedBox(height: 30.0)
  //           ],
  //         ),
  //         flex: 20,
  //       ),
  //       Expanded(
  //         child: Column(
  //           children: [
  //             Icon(isRejected ? Icons.cancel : Icons.motorcycle,
  //                 color: (isRejected
  //                     ? Colors.red
  //                     : (isOnDelivery ? Colors.green : Colors.grey)),
  //                 size: 35),
  //             SizedBox(height: 10.0),
  //             Text(
  //                 //ALTERA????O FEITA POR ELIZIER
  //                 isRejected
  //                     ? hasError
  //                         ? 'Ocorreu um erro no pedido'
  //                         : 'Pedido rejeitado'
  //                     : 'Saindo para entrega',
  //                 style: TextStyle(fontSize: 10),
  //                 maxLines: 3,
  //                 textAlign: TextAlign.center)
  //           ],
  //         ),
  //         flex: 20,
  //       ),
  //     ],
  //   );
  // }

  Widget _actionsComplete(Purchase purchase) {
    String rejectionReason =
        purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' ');
    bool isOnDelivery = purchase.status == 'ENTREGUE';
    bool isRejected = purchase.status == 'REJEITADO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';

    Color color = (isOnDelivery ? Colors.green : Colors.red[300])!;

    return Row(children: [
      Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width - 80,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: color,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
              child: isOutOfRange
                  ? Row(children: [
                      Icon(Icons.info_outline,
                          color: (Colors.red[300]), size: 24),
                      SizedBox(width: 5),
                      Text(
                        'Pedido fora da ??rea de atendimento.',
                        style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      )
                    ])
                  : (isRejected
                      ? Row(children: [
                          Icon(Icons.highlight_off,
                              color: (Colors.red[400]), size: 24),
                          SizedBox(width: 5),
                          Text(
                            'Pedido rejeitado pelo motivo abaixo:',
                            style: TextStyle(
                                color: Colors.red[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          )
                        ])
                      : Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: (Colors.green), size: 24),
                            SizedBox(width: 5),
                            Text(
                              'Pedido est?? saindo para entrega.',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            )
                          ],
                        ))))
    ]);
  }

  Widget _ongoingActions(Purchase purchase) {
    bool isDistributed = [
      'DISTRIBUIDO',
      'EM_ATENDIMENTO',
      'ENTREGUE',
      'REJEITADO',
      'FORA_DA_AREA_DE_ATENDIMENTO'
    ].contains(purchase.status);
    String rejectionReason =
        purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' ');
    bool isAccepted =
        ['EM_ATENDIMENTO', 'ENTREGUE', 'REJEITADO'].contains(purchase.status);
    bool isInCall = purchase.status == 'EM_ATENDIMENTO';
    bool isOnDelivery = purchase.status == 'ENTREGUE';
    bool isRejected = purchase.status == 'REJEITADO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    bool hasError = purchase.status == 'ABERTO';
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
                              semanticsLabel: 'Indicador de Progresso',
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
                      semanticsLabel: 'Indicador de Progresso',
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
    bool isEntregue = purchase.status == 'ENTREGUE';
    bool isInCall = purchase.status == 'EM_ATENDIMENTO';
    bool isOutOfRange = purchase.status == 'FORA_DA_AREA_DE_ATENDIMENTO';
    String rejectionReason =
        purchase.motivoRejeicao!.replaceAll(new RegExp(r'\+'), ' ');
    // String pharmacy = purchase.drugStore!.name;
    // List<String> phoneNums = purchase.drugStore!.phoneNumbers ?? [];

    if (purchase.status == 'ABERTO') {
      return Container();
    }

    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                                ? 'em an??lise'
                                : (purchase.status == 'ENTREGUE'
                                    ? 'saindo para entrega'
                                    : 'aguardando a farm??cia aceitar o pedido.'),
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
                  text: TextSpan(
                      text: 'Motivo da rejei????o: \n',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: '"$rejectionReason"',
                            style: TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700))
                      ]),
                )
              : Container(),
          isEntregue ? SizedBox(height: 10.0) : Container(),
          // isEntregue
          //     ? Align(
          //         alignment: Alignment.topLeft,
          //         child: RichText(
          //           text: TextSpan(
          //               text: 'Telefone${phoneNums.length > 1 ? 's' : ''}: ',
          //               style: TextStyle(color: Colors.black),
          //               children: phoneNums
          //                   .map((phoneNum) => TextSpan(
          //                       text: phoneNum,
          //                       style: TextStyle(
          //                           color: Colors.blue,
          //                           fontWeight: FontWeight.bold)))
          //                   .toList()),
          //         ),
          //       )
          //     : Container()
        ],
      ),
      padding: EdgeInsets.only(
        top: 7.0,
        bottom: 0.0,
      ),
    );
  }

  Widget _ongoingDeliveryAddress(Purchase purchase) {
    Address address = purchase.deliveryAddress!;
    var street = address.street;
    var number = address.number;
    var complement = address.complement;
    var neighborhood = address.neighborhood;

    if (street == null) {
      street = 'N??o informado';
    }
    if (street.trim() == 'null') {
      street = 'N??o informado';
    }
    if (street.trim() == '') {
      street = 'N??o informado';
    }

    if (number == null) {
      number = '';
    }
    if (number.trim() == 'null') {
      number = '';
    }
    if (number.trim() == '') {
      number = '';
    }

    if (complement == null) {
      complement = '';
    }
    if (complement.trim() == 'null') {
      complement = '';
    }
    if (complement.trim() == '') {
      complement = '';
    }

    if (neighborhood == null) {
      neighborhood = 'N??o informado';
    }
    if (neighborhood.trim() == 'null') {
      neighborhood = 'N??o informado';
    }
    if (neighborhood.trim() == '') {
      neighborhood = 'N??o informado';
    }

    if (address == null) return Container();
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Endere??o de entrega',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 0.0),
          Padding(
            child: Row(
              children: [
                address.street != null && address.street!.trim() != ''
                    ? Text(
                        'Rua: $street',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      )
                    : Spacer(),
                address.number != null && address.number!.trim() != ''
                    ? Text(
                        'N??: $number',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      )
                    : Container(),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            padding: EdgeInsets.only(top: 4.0, bottom: 0.0),
          ),
          Padding(
            child:
                address.complement != null && address.complement!.trim() != ''
                    ? Text(
                        'Complemento: $complement',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      )
                    : Container(),
            padding: EdgeInsets.only(top: 2.0, bottom: 0.0),
          ),
          Padding(
            child: Row(
              children: [
                address.neighborhood != null &&
                        address.neighborhood!.trim() != ''
                    ? Text(
                        'Bairro: $neighborhood',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w300),
                      )
                    : Container()
              ],
            ),
            padding: EdgeInsets.only(top: 2.0, bottom: 3.0),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.only(top: 20.0),
    );
  }

  Widget _oldPurchases() {
    bool havePurchases = _purchases.length > 0;

    return Column(
      children: [
        Padding(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              havePurchases ? 'Pedidos Conclu??dos' : '',
              style: _defaultTitleTextStyle,
            ),
          ),
          padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
        ),
        Column(
          children:
              _purchases.map((purchase) => _purchaseCell(purchase)).toList(),
        )
      ],
    );
  }

  Widget _purchaseCell(Purchase purchase) {
    return Padding(
      child: GestureDetector(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AutoSizeText(
                        'Pedido ${purchase.formattedID()} de ${_formattedDate(purchase.date!)}',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        'Status: ${purchase.formattedStatus() == "DISTRIBUIDO" ? "aguardando a farm??cia aceitar o pedido" : purchase.formattedStatus()}',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w300),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AutoSizeText(
                        'Forma de pagamento: ${purchase.getStringFormaPagamento()}',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w300),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        "Valor Total do Pedido: " +
                            purchase.getValorTotalDoPedidoString(),
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                        maxLines: 1,
                        textAlign: TextAlign.left,
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  flex: 90,
                ),
                Spacer(flex: 5),
                Expanded(
                  child: Text(
                    'Detalhes',
                    style: TextStyle(
                        color: AppColors.primary,
                        /* red */
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  flex: 25,
                )
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0, 2),
                      spreadRadius: 1.0)
                ],
                color: Colors.white),
            width: MediaQuery.of(context).size.width - 40),
        onTap: () => _purchaseDetails(purchase),
      ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  String _formattedDate(DateTime date) {
    String weekday = _weekdayToString(date);
    String day = (date.day >= 10) ? date.day.toString() : '0${date.day}';
    String month =
        (date.month >= 10) ? date.month.toString() : '0${date.month}';
    String year = date.year.toString();
    return '$day/$month/$year';
  }

  String _weekdayToString(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'SEG';
      case 2:
        return 'TER';
      case 3:
        return 'QUA';
      case 4:
        return 'QUI';
      case 5:
        return 'SEX';
      case 6:
        return 'S??B';
      case 7:
        return 'DOM';
      default:
        return 'NA';
    }
  }

  void _purchaseDetails(Purchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseCompletedPage(
          purchase: purchase,
          isFromPurchaseList: true,
        ),
        fullscreenDialog: true,
        settings: RouteSettings(name: 'PurchaseRoute'),
      ),
    );
  }

  @override
  void dispose() {
    PurchaseRepository().removeListener(() {});
    LoggedInNotifierService().removeListener(() {});
    super.dispose();
  }
}
