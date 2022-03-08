import 'dart:ui';

import 'package:afarma/model/Medication.dart';
import 'package:afarma/model/User.dart';
import 'package:afarma/page/profile/ChangeAddressPage.dart';
import 'package:afarma/page/search/ProductDetailPage.dart';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:afarma/helper/AppColors.dart';

import '../RegisterPage.dart';

class PromosPage extends StatefulWidget {
  PromosPage({
    key,
    required this.scrollController,
    required this.pageController,
    this.tabIndex,
    required this.onShowTabBar,
  }) : super(key: key);

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex? tabIndex;
  final VoidCallback onShowTabBar;

  @override
  PromosPageState createState() => PromosPageState();
}

class PromosPageState extends State<PromosPage> {
  List<Medication> get _meds => MedicationRepository().medsPromo;
  bool get _hasMore => MedicationRepository().hasMorePromo;
  bool searching = false;

  // Infinite loading
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    if (!mounted) return;

    // Setup the listener.
    widget.scrollController.addListener(() {
      if (!mounted) return;

      setState(() {
        this._loading = false;
      });

      if (widget.scrollController.position.atEdge &&
          widget.scrollController.position.pixels != 0) {
        setState(() {
          this._loading = true;
        });
        if (MedicationRepository().hasMore) {
          // You're at the bottom.
          MedicationRepository().fetchMedications('', '', true).then((_) {
            setState(() {
              this._loading = false;
            });
          });
        } else {
          setState(() {
            this._loading = false;
          });
        }
      }
    });

    MedicationRepository().addListener(() {
      if (mounted) {
        setState(() {
          this._loading = false;
        });
      }
    });

    _fetchData();
  }

  Future<void> addLocation() async {
    setState(() {
      this.searching = true;
    });

    bool result = await showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actions: [
                FlatButton(
                  child: Text('Não quero informar'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text('Vou informar'),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
              content: Text(
                  'Para ver as promoções é necessário informar a sua localização.'),
            ),
          );
        },
        context: context);
    if (result) {
      var returnChangeAddress = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeAddressPage(),
        ),
      );

      if (returnChangeAddress != null) {
        // Tenta novamente
        _fetchData();
      } else if (!MedicationRepository().hasPromocaoLatLon()) {
        backToHome();
      }
    } else {
      backToHome();
    }
  }

  void backToHome() {
    widget.pageController.jumpToPage(0);
    widget.tabIndex!.newIndex(0);
  }

  @override
  void dispose() {
    super.dispose();
    MedicationRepository().removeListener(() {});
    widget.scrollController.removeListener(() {});
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

  Future<void> _fetchData() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (User.instance == null) {
        await _alert('Entre ou Crie sua conta para ver as promoções.');
        bool? returnLoginRegister = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(isFromPromocoes: true),
            settings: RouteSettings(name: 'RegisterRoute'),
          ),
        );

        if (returnLoginRegister == null || !returnLoginRegister) {
          backToHome();
          return;
        }
      }

      // Veiricação se existe lat e lon setado na promoção, se não tem tem que avisar o usuário que tem que solecionar
      if (!MedicationRepository().hasPromocaoLatLon()) {
        addLocation();
      } else {
        this.searching = true;
        MedicationRepository().cleanListPromo();

        MedicationRepository().fetchMedications('', '', true).then((_) {
          setState(() {});
          this.searching = false;
        });
      }
    });
  }

  void _viewProductDetail(Medication med) async {
    FocusScope.of(context).unfocus();
    await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(product: med, isFromPromo: true)))
        .then((value) {
      if (value == true) {
        // Se adicionou produto vai para a cesta
        widget.pageController.jumpToPage(1);
        widget.tabIndex!.newIndex(1);
      }
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
          'Promoções',
          style: TextStyle(),
        ),
        leading: IconButton(
          icon: Icon(Icons.location_on),
          onPressed: addLocation,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => {
              widget.pageController.jumpToPage(0),
              widget.tabIndex!.newIndex(0)
            },
          )
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: _mainBody(),
      ),
    );
  }

  Widget _mainBody() {
    List<Medication> meds = _meds.toList();

    String text = "Buscando nas Promoções";

    Container title = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(children: [
        SizedBox(height: 5),
        // _pharmacyImage(),
        title,
        Divider(
          height: 2,
          thickness: 2,
          indent: 10,
          endIndent: 10,
          color: AppColors.primary,
        ),
        _products(meds),
        SizedBox(height: 20),
        _loading
            ? Center(
                child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: CircularProgressIndicator(),
              ))
            : _hasMore
                ? SizedBox(height: 0.0)
                : Divider(
                    height: 2,
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                    color: AppColors.primary,
                  ),
        SizedBox(height: 120),
      ]),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _products(List<Medication> meds) {
    if (this.searching) {
      return Container(
        width: MediaQuery.of(context).size.width - 50,
        height: 300,
        child: Center(
          child: Text(
            'Carregando produtos...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ),
      );
    } else if (meds.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width - 50,
        height: 300,
        child: Center(
          child: Text(
            'Nenhum produto encontrado!',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 18),
          ),
        ),
      );
    }

    List<Widget> widgets = [];
    Medication? before;
    int counter = 1;
    for (Medication m in meds) {
      if (before == null) {
        if (meds.length == counter) {
          widgets.add(Row(
            children: [_productCell(m), Container()],
            crossAxisAlignment: CrossAxisAlignment.start,
          ));
        } else {
          before = m;
        }
      } else {
        widgets.add(Row(
          children: [_productCell(before), _productCell(m)],
          // crossAxisAlignment: CrossAxisAlignment.center,
        ));
        before = null;
      }

      counter += 1;
    }

    return Column(
      children: widgets,
    );
  }

  Widget _productCell(Medication med) {
    double widthMed = (MediaQuery.of(context).size.width / 2) - 20;

    return GestureDetector(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            width: widthMed,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    child: med.medImage(),
                    tag: med.id +
                        "-list-" +
                        DateTime.now().microsecondsSinceEpoch.toString(),
                  ),
                  Positioned(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            text: 'Comprar'),
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    top: MediaQuery.of(context).size.width / 3.9,
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          Container(
            width: widthMed,
            height: 80,
            padding: EdgeInsets.only(top: 8, left: 5, right: 5),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: AutoSizeText(
                    "Preço Médio: " + med.getPrecoMedioFormated(),
                    // med.lojaPromocao!,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 14,
                    maxFontSize: 25,
                    maxLines: 1,
                  ),
                ),
                AutoSizeText(
                  med.nome,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 12,
                  maxFontSize: 13,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _viewProductDetail(med),
      onLongPress: () => _viewProductDetail(med),
    );
  }
}
