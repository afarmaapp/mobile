import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Cart.dart';
import 'package:afarma/model/Medication.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/page/RegisterPage.dart';
import 'package:afarma/page/purchase/CompletePurchasePage.dart';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ComparativePage extends StatefulWidget {
  ComparativePage();

  @override
  _ComparativePageState createState() => _ComparativePageState();
}

class _ComparativePageState extends State<ComparativePage> {
  List<Medication> get _meds => Cart().meds;
  List<int> get _amounts => Cart().amounts;
  List<bool> get _promo => Cart().promo;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic comparatives = [];
  dynamic comparativesJSON = [];
  String comparativesStringTest = "";
  String comparativesJSONStringTest = "";
  int indexOfAfarma = -1;

  late List<dynamic> itemsMenorValor;
  late LinkedHashMap<String, dynamic> itemsComparative;

  var valorCestaController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    MedicationRepository().cotarJSON(_meds, _amounts).then((response) {
      // List<dynamic> clone = []..addAll(response);
      // response.addAll(clone);
      comparativesJSON = response;

      comparativesJSONStringTest = jsonEncode(comparativesJSON);
      setState(() {});
    });
    MedicationRepository().cotar(_meds, _amounts).then((response) {
      // List<dynamic> clone = []..addAll(response);
      // response.addAll(clone);
      comparatives = response;
      comparativesStringTest = jsonEncode(comparatives);
      setState(() {});
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
            bottomRight: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Comparativo de Cesta',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: _mainBody(),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
      ),
      key: _scaffoldKey,
    );
  }

  Widget _mainBody() {
    if (comparatives.length == 0) {
      return Center(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    List<Widget> children = [
      SizedBox(
        height: 15.0,
      )
    ];

    List<dynamic> itemsAfarma = [];

    double widthFarmacia = (MediaQuery.of(context).size.width / 3) - 28;

    int idx = 0;
    List<Widget> farmaciasValoresWidgets = [];

    int indexMenorValor = takeIndexMenorValorCotacao();
    itemsMenorValor = makeItemsFromComparative(
        jsonDecode(comparativesJSON[indexMenorValor]["line"]));

    valorCestaController.updateValue(comparatives[indexMenorValor]["total"]);

    for (LinkedHashMap<String, dynamic> farmacia in comparatives) {
      double val = double.tryParse(farmacia["total"].toString()) ?? 0.0;
      LinkedHashMap<String, dynamic> comparativeHashMap = comparativesJSON[idx];
      LinkedHashMap<String, dynamic> lineHashMap =
          jsonDecode(comparativeHashMap["line"]);

      List<dynamic> items = getItemsFromComparative(lineHashMap);

      var valorMaskControlller = MoneyMaskedTextController(
          decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
      valorMaskControlller.updateValue(val);

      String logo = 'logo-red.png';
      bool isAfarmaToTap = false;

      if (farmacia["loja"] == "VENANCIO") {
        logo = 'logo-venancio.png';
      } else if (farmacia["loja"] == "PACHECO") {
        logo = 'logo-pacheco.png';
      } else if (farmacia["loja"] == "RAIA") {
        logo = 'logo-raia.png';
      } else if (farmacia["loja"] == "aFarma") {
        indexOfAfarma = idx;
        itemsAfarma = items;
        isAfarmaToTap = true;
        itemsComparative = farmacia;
      }

      var cFarmaciaMenorValor = PopupMenuButton(
        enableFeedback: false,
        // enabled: false,
        offset: Offset(0, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Stack(
          children: [
            Container(
              width: widthFarmacia,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.red, width: 3.0)),
              child: Column(
                children: [
                  Center(
                      child: Image.asset(
                    'assets/images/' + logo,
                    fit: BoxFit.fitWidth,
                  )),
                  // SizedBox(height: 5.0),
                  // AutoSizeText(
                  //   farmacia["loja"],
                  //   style: TextStyle(fontWeight: FontWeight.w400),
                  //   textAlign: TextAlign.center,
                  //   maxLines: 1,
                  // ),
                  SizedBox(height: 10.0),
                  Text(
                    valorMaskControlller.text,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  child: Text("MENOR PREÇO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ))
          ],
        ),
        itemBuilder: (context) {
          return List.generate(
            items.length,
            (index) => index == 0
                ? PopupMenuItem(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            farmacia["loja"] == "VENANCIO"
                                ? "assets/images/logo-venancio.png"
                                : (farmacia["loja"] == "PACHECO"
                                    ? "assets/images/logo-pacheco.png"
                                    : "assets/images/logo-raia.png"),
                            height: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Center(
                                child: Icon(Icons.add_circle_outline,
                                    color: (Colors.red[300]), size: 27),
                              ),
                              SizedBox(width: 5.0),
                              Flexible(
                                child: Text(
                                  '${items[index]["a$index" + "nome_$index"]}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                '${items[index]["qtde_$index"]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                valueItemFormat(
                                    items[index]["a${index}valor_$index"]),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : PopupMenuItem(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Center(
                            child: Icon(Icons.add_circle_outline,
                                color: (Colors.red[300]), size: 27),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                              '${items[index]["a$index" + "nome_$index"]}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            '${items[index]["qtde_$index"]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            valueItemFormat(
                                items[index]["a${index}valor_$index"]),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        },
      );

      var cFarmacia = PopupMenuButton(
        enableFeedback: false,
        // enabled: false,
        offset: Offset(0, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Container(
          width: widthFarmacia,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1.0)),
          child: Column(
            children: [
              Center(
                  child: Image.asset(
                'assets/images/' + logo,
                fit: BoxFit.fitWidth,
              )),
              // SizedBox(height: 5.0),
              // AutoSizeText(
              //   farmacia["loja"],
              //   style: TextStyle(fontWeight: FontWeight.w400),
              //   textAlign: TextAlign.center,
              //   maxLines: 1,
              // ),
              SizedBox(height: 10.0),
              Text(
                valorMaskControlller.text,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        itemBuilder: (context) {
          return List.generate(
            items.length,
            (index) => index == 0
                ? PopupMenuItem(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            farmacia["loja"] == "VENANCIO"
                                ? "assets/images/logo-venancio.png"
                                : (farmacia["loja"] == "PACHECO"
                                    ? "assets/images/logo-pacheco.png"
                                    : "assets/images/logo-raia.png"),
                            height: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Center(
                                child: Icon(Icons.add_circle_outline,
                                    color: (Colors.red[300]), size: 27),
                              ),
                              SizedBox(width: 5.0),
                              Flexible(
                                child: Text(
                                  '${items[index]["a$index" + "nome_$index"]}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                '${items[index]["qtde_$index"]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                valueItemFormat(
                                    items[index]["a${index}valor_$index"]),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : PopupMenuItem(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Center(
                            child: Icon(Icons.add_circle_outline,
                                color: (Colors.red[300]), size: 27),
                          ),
                          SizedBox(width: 5.0),
                          Flexible(
                            child: Text(
                              '${items[index]["a$index" + "nome_$index"]}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            '${items[index]["qtde_$index"]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            valueItemFormat(
                                items[index]["a${index}valor_$index"]),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        },
      );
      if (farmacia["total"] == comparatives[indexMenorValor]["total"]) {
        farmaciasValoresWidgets.add(cFarmaciaMenorValor);
      } else {
        if (farmacia["loja"] != "aFarma") {
          farmaciasValoresWidgets.add(cFarmacia);
        }
      }
      idx++;
    }

    Container containerComparative = Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            child: AutoSizeText(
              "Simulamos a sua compra em outras farmácias e vamos garantir o preço mais baixo. \nClique nas caixas e confira!",
              maxLines: 3,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: farmaciasValoresWidgets,
              runSpacing: 15.0,
              spacing: 15.0,
            ),
          ),
        ],
      ),
    );

    Container orderResume = Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: Colors.grey[300],
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            child: AutoSizeText(
              "Resumo do Pedido",
              maxLines: 3,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Column(
                  children: List.generate(
                    itemsMenorValor.length,
                    (index) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${itemsMenorValor[index]["nome"]}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '${itemsMenorValor[index]["qtde"]}x',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 25.0),
                        Text(
                          valueItemFormat(itemsMenorValor[index]["valor"]),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Valor da cesta: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      valorCestaController.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  height: 20,
                  color: Colors.grey[600],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo-red.png',
                      width: 90,
                    ),
                    Text.rich(
                      TextSpan(
                        text: '${valorCestaController.text}\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.red[500],
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                        ),
                        children: [
                          TextSpan(
                            text: valueItemFormat(Cart().lowerValue!),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.grey[900],
                              decoration: TextDecoration.none,
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );

    children.add(containerComparative);
    children.add(SizedBox(height: 15.0));
    children.add(orderResume);
    children.add(SizedBox(height: 15.0));
    children.add(Row(children: _buttons()));

    return SingleChildScrollView(
      child: Column(children: children),
    );
  }

  int takeIndexMenorValorCotacao() {
    LinkedHashMap<String, dynamic> menorValor = comparatives[0];
    int index = 0;
    int indexMenorValor = 0;

    for (LinkedHashMap<String, dynamic> farmacia in comparatives) {
      if (farmacia["loja"] != "aFarma") {
        if (farmacia["total"] < menorValor["total"]) {
          menorValor = farmacia;
          indexMenorValor = index;
        }

        index++;
      }
    }

    return indexMenorValor;
  }

  String valueItemFormat(valorItem) {
    var valorMaskController = MoneyMaskedTextController(
        decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
    valorMaskController.updateValue(valorItem);
    return valorMaskController.text;
  }

  List<dynamic> getItemsFromComparative(lineHashMap) {
    bool active = true;
    int indexLine = 0;
    String itemsString = '[';

    while (active) {
      if (lineHashMap.containsKey("a${indexLine}nome_$indexLine")) {
        if (indexLine == 0) {
          itemsString +=
              '{"a${indexLine}nome_$indexLine": "${lineHashMap["a$indexLine" + "nome_$indexLine"]}", "ean_$indexLine": "${lineHashMap["ean_$indexLine"]}", "qtde_$indexLine": ${lineHashMap["qtde_$indexLine"]}, "a${indexLine}valor_$indexLine": ${lineHashMap["a${indexLine}valor_$indexLine"]}}';
        } else {
          itemsString +=
              ', {"a${indexLine}nome_$indexLine": "${lineHashMap["a$indexLine" + "nome_$indexLine"]}", "ean_$indexLine": "${lineHashMap["ean_$indexLine"]}", "qtde_$indexLine": ${lineHashMap["qtde_$indexLine"]}, "a${indexLine}valor_$indexLine": ${lineHashMap["a${indexLine}valor_$indexLine"]}}';
        }
      } else {
        itemsString += ']';
        active = false;
      }

      indexLine++;
    }

    return jsonDecode(itemsString);
  }

  List<dynamic> makeItemsFromComparative(lineHashMap) {
    bool active = true;
    int indexLine = 0;
    String itemsString = '[';

    while (active) {
      if (lineHashMap.containsKey("a${indexLine}nome_$indexLine")) {
        if (indexLine == 0) {
          itemsString +=
              '{"nome": "${lineHashMap["a$indexLine" + "nome_$indexLine"]}", "ean": "${lineHashMap["ean_$indexLine"]}", "qtde": ${lineHashMap["qtde_$indexLine"]}, "valor": ${lineHashMap["a${indexLine}valor_$indexLine"]}}';
        } else {
          itemsString +=
              ', {"nome": "${lineHashMap["a$indexLine" + "nome_$indexLine"]}", "ean": "${lineHashMap["ean_$indexLine"]}", "qtde": ${lineHashMap["qtde_$indexLine"]}, "valor": ${lineHashMap["a${indexLine}valor_$indexLine"]}}';
        }
      } else {
        itemsString += ']';
        active = false;
      }

      indexLine++;
    }

    return jsonDecode(itemsString);
  }

  void viewValues() {
    print(itemsComparative);
    showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Fechar'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              content: Container(
                height: 200,
                child: Column(
                  children: [
                    Text('Valor dos Produtos',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18)),
                    SizedBox(height: 25.0),
                    Column(
                      children: _meds
                          .map((med) => medicationComparative(med))
                          .toList(),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        context: context);
  }

  List<Widget> _buttons() {
    return [
      Expanded(
        child: ButtonTheme(
          child: RaisedButton(
            child: AutoSizeText(
              'Continuar',
              style: TextStyle(color: Colors.white),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            color: AppColors.secondary,
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

  Widget medicationComparative(Medication med) {
    return Container(
      width: 250,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1.0)),
      child: Row(
        children: [
          Center(
            child: Icon(Icons.add_circle_outline,
                color: (Colors.red[300]), size: 27),
          ),
          SizedBox(width: 5.0),
          Text(
            med.nome,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 5.0),
          Text(
            '${med.quantidade}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 5.0),
          Text(
            '${med.precoMedio}',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  void _completePurchase() async {
    if (User.instance == null) {
      // _alert('Autentique-se para fazer um pedido.');
      await _alert('Crie sua conta para concluir o pedido.');
      final a = await Navigator.push(
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletePurchasePage(),
        settings: RouteSettings(name: 'PurchaseRoute'),
      ),
    );
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
      context: context,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
