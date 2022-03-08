import 'package:afarma/formatters/MoneyFormatter/MoneyFormatter.dart';
import 'package:afarma/model/popularModels/Medication.dart';
// import 'package:afarma/page/afarmaPopular/MainTabController.dart';
import 'package:afarma/page/afarmaPopular/completePurchase/CompletePurchaseController.dart';
import 'package:afarma/page/afarmaPopular/home/ProductDetailController.dart';
import 'package:afarma/page/afarmaPopular/profile/RegisterController.dart';
import 'package:afarma/repository/popularRepositories/Cart.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CartController extends StatefulWidget {
  CartController(
      {required this.scrollController,
      required this.pageController,
      required this.tabIndex,
      required this.onShowTabBar});

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex tabIndex;
  final VoidCallback onShowTabBar;

  @override
  _CartControllerState createState() => _CartControllerState();
}

class _CartControllerState extends State<CartController> {
  List<Medication?>? get _meds => Cart().meds;
  List<int?>? get _amounts => Cart().amounts;

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {
            widget.pageController.previousPage(
                duration: Duration(milliseconds: 600), curve: Curves.ease),
            widget.tabIndex.newIndex(0)
          },
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Cesta',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: _mainBody(),
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
      ),
      key: _scaffoldKey,
    );
  }

  Widget _mainBody() {
    if (_meds == null || _meds!.length == 0) {
      return Center(
        child: Image.asset('assets/images/emptyCart.png'),
      );
    }
    List<Widget> children = [
      SizedBox(
        height: 20.0,
      )
    ];
    _meds!.forEach((map) {
      int index = _meds!.indexOf(map);
      children.addAll([
        GestureDetector(
          child: _medicationCell(index),
          onTap: () => _displayMedication(index),
        ),
        SizedBox(height: 20.0)
      ]);
    });
    if (Cart().needsPayment()) {
      children.add(Padding(
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Subtotal: ${MoneyFormatter.format(Cart().paymentAmount())}',
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        padding: EdgeInsets.only(bottom: 10, right: 10),
      ));
    }
    children.add(Row(
      children: [
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
                'Concluir pedido',
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              color: Colors.red,
              onPressed: () => _completePurchase(),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            height: 50,
          ),
          flex: 60,
        ),
      ],
    ));
    return SingleChildScrollView(
      child: Column(
          children: children +
              [
                SizedBox(height: 20.0),
              ]),
      controller: widget.scrollController,
    );
  }

  Widget _medicationCell(int index) {
    Medication med = _meds![index]!;
    int amount = _amounts![index]!;
    double? price = med.price;
    double width = MediaQuery.of(context).size.width - 40;
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
              Expanded(
                child: Image(image: med.medImage()),
                flex: 20,
              ),
              Spacer(flex: 5),
              Expanded(
                child: Column(
                  children: [
                    AutoSizeText(
                      med.name!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                      maxLines: 25,
                    ),
                    AutoSizeText(
                      med.amount!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                      maxLines: 25,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                flex: 35,
              ),
              Expanded(
                child: Column(
                  children: [
                    AutoSizeText(
                      '${amount.toString()} unidade${amount > 1 ? 's' : ''}',
                      //price != -1 ? '${amount.toString()} unidade${amount > 1 ? 's' : ''}' : 'Quantidade',
                      //'Quantidade${price != -1 ? ': ' + amount.toString() : ''}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    price != -1
                        ? AutoSizeText(
                            //price != -1 ? MoneyFormatter.format(price * amount) : amount.toString(),
                            MoneyFormatter.format(price! * amount),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          )
                        : Container()
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                flex: 25,
              ),
              SizedBox(width: 20.0)
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    blurRadius: 5,
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(2, 2),
                    spreadRadius: 1),
              ],
              color: Colors.white),
          height: 110,
          width: width,
        ),
        direction: DismissDirection.endToStart,
        key: Key(med.amount! + med.name!),
        onDismissed: (_) => _removeMedication(med));
  }

  void _removeMedication(Medication med) {
    showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text('Sim'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    Cart().removeMed(med);
                  });
                  widget.onShowTabBar();
                  _scaffoldKey.currentState!.showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      '${med.name} removido!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color.fromRGBO(255, 49, 49, 1), /* red */
                  ));
                },
              ),
              FlatButton(
                child: Text('Não'),
                onPressed: () => Navigator.pop(context),
              )
            ].reversed.toList(),
            content: Text(
                'Tem certeza que deseja remover ${med.name} da sua cesta?'),
          );
        },
        barrierDismissible: false,
        context: context);
  }

  void _cleanCart() {
    if (_meds!.length == 0) return;
    showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text('Sim'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    Cart().clear();
                  });
                  widget.onShowTabBar();
                  _scaffoldKey.currentState!.showSnackBar(SnackBar(
                    content: Text(
                      'Produtos removidos',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color.fromRGBO(255, 49, 49, 1), /* red */
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
          );
        },
        barrierDismissible: false,
        context: context);
  }

  void _completePurchase() async {
    if (User.instance == null) {
      // _alert('Autentique-se para fazer um pedido.');
      await _alert('Crie sua conta para concluir o pedido.');
      final a = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterController(isFromPurchase: true),
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
    final a = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletePurchaseController(),
        settings: RouteSettings(name: 'PurchaseRoute'),
      ),
    );
    widget.pageController
        .nextPage(duration: Duration(milliseconds: 600), curve: Curves.ease);
    widget.tabIndex.nextIndex();
  }

  void _displayMedication(int medIndex) async {
    final a = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProductDetailController(product: _meds![medIndex]),
            fullscreenDialog: true));
    if (mounted) setState(() {});
  }

  void _loadingAlert(String title) async {
    await showDialog(
        barrierDismissible: true,
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

  Future<void> _alert(String content) async {
    return await showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
            content: Text(content),
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
