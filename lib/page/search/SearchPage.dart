import 'dart:async';
import 'dart:developer';
import 'package:afarma/model/Medication.dart';
import 'package:afarma/repository/MedicationRepository.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:afarma/helper/AppColors.dart';

import 'ProductDetailPage.dart';

class SearchPage extends StatefulWidget {
  SearchPage(
      {key,
      required this.scrollController,
      required this.pageController,
      this.tabIndex})
      : super(key: key);

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex? tabIndex;

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  List<Medication> get _meds => MedicationRepository().meds;
  bool get _hasMore => MedicationRepository().hasMore;
  Timer? _debounce;
  String? departamentoId;
  String? departamentoName;
  String? textSearch;
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
          MedicationRepository()
              .fetchMedications(this.textSearch, this.departamentoId, false)
              .then((_) {
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
  }

  void search(String? q, String? departamentoId, String? departamentoName) {
    if (!mounted) return;
    setState(() {
      this.textSearch = q;
      this.departamentoId = departamentoId;
      this.departamentoName = departamentoName;
    });
    _fetchData();
  }

  void _fetchData() {
    this.searching = true;
    MedicationRepository().cleanList();

    if (this._debounce != null && this._debounce!.isActive) _debounce!.cancel();
    this._debounce = Timer(const Duration(milliseconds: 750), () {
      log("BUSCANDO..." +
          this.textSearch.toString() +
          " / " +
          this.departamentoId.toString());

      MedicationRepository()
          .fetchMedications(this.textSearch, this.departamentoId, false)
          .then((_) {
        setState(() {});
        this.searching = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debounce!.cancel();
    MedicationRepository().removeListener(() {});
    widget.scrollController.removeListener(() {});
  }

  void _viewProductDetail(Medication med) async {
    FocusScope.of(context).unfocus();
    await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: med)))
        .then((value) {
      if (value == true) {
        // Se adicionou produto vai para a cesta
        widget.pageController.nextPage(
            duration: Duration(milliseconds: 600), curve: Curves.ease);
        widget.tabIndex!.nextIndex();
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: _mainBody(),
    );
  }

  Widget _mainBody() {
    List<Medication> meds = _meds.toList();

    String text = "Buscando ";

    text += (this.textSearch == null || this.textSearch == ''
        ? 'tudo '
        : "\"" + this.textSearch! + "\" ");
    text += (this.departamentoName == null
        ? 'em todos os departamentos'
        : 'em ' + this.departamentoName!.toUpperCase() == 'SAUDE E BEM ESTAR'
            ? 'Saúde e Bem estar'
            : this.departamentoName!.toUpperCase());

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
        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
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

    // widgets.add(
    //   SizedBox(height: 90.0),
    // );

    return Column(
      children: widgets,
    );
  }

  Widget _productCell(Medication med) {
    // final double positionAddButton = -50.0;

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
                  Container(
                    margin: EdgeInsets.only(bottom: 25),
                    child: Hero(
                      child: med.medImage(),
                      tag: med.id +
                          "-list-" +
                          DateTime.now().microsecondsSinceEpoch.toString(),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 70, vertical: 10),
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
                    top: MediaQuery.of(context).size.width / 2.8,
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(color: med.departamento.color!, width: 4.0),
                // border: Border.all(color: AppColors.primary, width: 4.0),
                borderRadius: BorderRadius.circular(20)),
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
                    "A partir de: " + med.getPrecoMedioFormated(),
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
                // Expanded(
                //   child:
                AutoSizeText(
                  med.nome,
                  // "Julian Cesar dos Santos Carolina Helena",
                  // style: TextStyle(
                  //     color: Colors.black,
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w500),
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
