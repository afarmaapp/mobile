import 'dart:ui';

import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Cart.dart';
import 'package:afarma/model/Medication.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/page/HomePage.dart';
import 'package:afarma/page/RegisterPage.dart';
import 'package:afarma/page/profile/ProfilePage.dart';
import 'package:afarma/page/purchase/ComparativePage.dart';
import 'package:afarma/page/purchase/CompletePurchasePage.dart';
import 'package:afarma/page/search/ProductDetailPage.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

class CartPage extends StatefulWidget {
  CartPage(
      {required this.scrollController,
      required this.pageController,
      required this.tabIndex,
      required this.onShowTabBar});

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex tabIndex;
  final VoidCallback onShowTabBar;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Medication> get _meds => Cart().meds;
  List<int> get _amounts => Cart().amounts;
  List<bool> get _promo => Cart().promo;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Cart().addListener(() {
      if (mounted) setState(() {});
    });
  }

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
          'Cesta',
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
              setState(() {});
            });
          },
        ),
        actions: [
          IconButton(
              onPressed: () => {
                    TabIndex().newIndex(0),
                    widget.pageController.jumpToPage(0)
                    // setState(() {})
                  },
              icon: Icon(Icons.arrow_back))
        ],
      ),
      body: Container(
        child: _mainBody(),
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
      ),
      key: _scaffoldKey,
    );
  }

  Widget _mainBody() {
    if (_meds.length == 0) {
      return Center(
        child: Image.asset('assets/images/emptyCart.png'),
      );
    }
    List<Widget> children = [
      SizedBox(
        height: 15.0,
      )
    ];

    children.add(Row(children: _buttons()));

    children.add(SizedBox(height: 15.0));

    // children.add(Container(
    //   padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
    //   child: AutoSizeText(
    //     "Preço Médio da Cesta: " + Cart().paymentAmountFormated(),
    //     style: TextStyle(
    //       color: AppColors.secondary,
    //       fontWeight: FontWeight.bold,
    //     ),
    //     textAlign: TextAlign.center,
    //     minFontSize: 18,
    //     maxFontSize: 25,
    //     maxLines: 1,
    //   ),
    // ));

    _meds.forEach((map) {
      int index = _meds.indexOf(map);
      children.addAll([
        GestureDetector(
          child: _medicationCell(index),
          onTap: () => _displayMedication(index),
        ),
        SizedBox(height: 15.0)
      ]);
    });

    _meds.length > 6
        ? children.add(Row(children: _buttons()))
        : children.add(Container());

    children.add(
      ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        child: RaisedButton(
          child: AutoSizeText(
            'ADICIONAR MAIS ITENS',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          color: Colors.blue,
          onPressed: () => {
            widget.pageController.jumpToPage(0),
            widget.tabIndex.newIndex(0)
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        height: 40,
      ),
    );

    return SingleChildScrollView(
      child: Column(children: children + [SizedBox(height: 150.0)]),
      controller: widget.scrollController,
    );
  }

  List<Widget> _buttons() {
    return [
      Expanded(
        child: ButtonTheme(
          child: RaisedButton(
            child: AutoSizeText(
              'Limpar cesta',
              style: TextStyle(color: Colors.white),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            color: Colors.blue,
            onPressed: () => _cleanCart(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              'Concluir pedido',
              style: TextStyle(color: Colors.white),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            color: Colors.red,
            onPressed: () => _completePurchase(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          height: 50,
        ),
        flex: 60,
      ),
    ];
  }

  Widget _medicationCell(int index) {
    Medication med = _meds[index];
    int amount = _amounts[index];
    bool promo = _promo[index];
    // double width = MediaQuery.of(context).size.width - 0;

    return Dismissible(
        background: Container(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Apagar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.red),
          padding: EdgeInsets.only(right: 30.0),
        ),
        child: Container(
          child: Row(
            children: [
              Spacer(flex: 1),
              Expanded(
                child: med.medImageFit(BoxFit.fitHeight),
                flex: 15,
              ),
              Spacer(flex: 1),
              Expanded(
                child: Column(
                  children: [
                    AutoSizeText(
                      med.nome,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                      maxLines: 25,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          promo
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 1),
                                  margin: EdgeInsets.only(right: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xFFFDD835),
                                      )),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.monetization_on_outlined,
                                        color: Colors.yellow[600],
                                        size: 14,
                                      ),
                                      Text('PROMO',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.yellow[600],
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                )
                              : Container(),
                          AutoSizeText(
                            '${amount.toString()} unidade${amount > 1 ? 's' : ''}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      width: MediaQuery.of(context).size.width - 150,
                      child: AutoSizeText(
                        'A partir de: ${med.getPrecoMedioFormated()}',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                flex: 25,
              ),
              Spacer(flex: 1),
              SizedBox(width: 30.0)
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  color: Colors.grey.withOpacity(0.2),
                  offset: Offset(2, 2),
                  spreadRadius: 1),
            ],
          ),
          height: 100,
          width: MediaQuery.of(context).size.width,
        ),
        direction: DismissDirection.endToStart,
        key: Key(med.quantidade.toString() + med.nome),
        onDismissed: (_) => _removeMedication(med));
  }

  void _removeMedication(Medication med) {
    setState(() {
      Cart().removeMed(med);
    });
    // showDialog(
    //   builder: (context) {
    //     return AlertDialog(
    //       actions: [
    //         FlatButton(
    //           child: Text('Sim'),
    //           onPressed: () {
    //             Navigator.pop(context);
    //             setState(() {
    //               Cart().removeMed(med);
    //             });
    //             widget.onShowTabBar();
    //             _scaffoldKey.currentState!.showSnackBar(SnackBar(
    //               behavior: SnackBarBehavior.floating,
    //               content: Text(
    //                 '${med.nome} removido!',
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //               backgroundColor: AppColors.primary, /* red */
    //             ));
    //           },
    //         ),
    //         FlatButton(
    //           child: Text('Não'),
    //           onPressed: () => Navigator.pop(context),
    //         )
    //       ].reversed.toList(),
    //       content:
    //           Text('Tem certeza que deseja remover ${med.nome} da sua cesta?'),
    //     );
    //   },
    //   barrierDismissible: false,
    //   context: context,
    // );
  }

  void _cleanCart() {
    if (_meds.length == 0) return;
    showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      Cart().clear();
                      widget.pageController.jumpToPage(0);
                      widget.tabIndex.newIndex(0);
                    });
                    widget.onShowTabBar();
                    _scaffoldKey.currentState!.showSnackBar(SnackBar(
                      content: Text(
                        'Produtos removidos',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.primary, /* red */
                    ));
                  },
                ),
                FlatButton(
                  child: Text('Não'),
                  onPressed: () => Navigator.pop(context),
                )
              ].reversed.toList(),
              content: Text(
                  'Tem certeza que deseja retirar todos os produtos da sua cesta?'),
            ),
          );
        },
        barrierDismissible: false,
        context: context);
  }

  void _completePurchase() async {
    if (User.instance == null) {
      // _alert('Autentique-se para fazer um pedido.');
      await _alert('Crie sua conta para concluir o pedido.');
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterPage(isFromPurchase: true),
              settings: RouteSettings(name: 'RegisterRoute')));
      return;
    }
    _loadingAlert('Gerando pedido...');
    final cartResp = await Cart().getCartID();
    Navigator.pop(context);
    if (cartResp == null || cartResp.trim() == '') {
      _alert('Ocorreu um erro ao gerar o pedido, tente novamente mais tarde');
      return;
    }
    var a;
    if (Cart().meds.length > 1) {
      a = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComparativePage(),
          settings: RouteSettings(name: 'ComparativeRoute'),
        ),
      );
    } else {
      showModalBottomSheet(
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: 320,
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset('assets/images/home-aviso.png'),
                    SizedBox(height: 25.0),
                    GestureDetector(
                      onTap: () async => {
                        Navigator.pop(context),
                        a = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletePurchasePage(),
                            settings: RouteSettings(name: 'PurchaseRoute'),
                          ),
                        )
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.primary,
                          // border: Border.all(
                          //   color: AppColors.primary,
                          // ),
                        ),
                        child: Text(
                          'CONTINUAR MESMO ASSIM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () => {
                        widget.pageController.jumpToPage(0),
                        widget.tabIndex.newIndex(0),
                        Navigator.pop(context)
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue,
                        ),
                        child: Text(
                          'ADICIONAR MAIS ITENS',
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
    if (a != null) {
      widget.pageController.jumpToPage(3);
      widget.tabIndex.newIndex(3);
    }
  }

  void _displayMedication(int medIndex) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: _meds[medIndex]),
            fullscreenDialog: true));
    if (mounted) setState(() {});
  }

  void _loadingAlert(String title) async {
    await showDialog(
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

  Future<void> _alert(String content) async {
    return await showDialog(
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

  @override
  void dispose() {
    Cart().removeListener(() {});
    super.dispose();
  }
}
