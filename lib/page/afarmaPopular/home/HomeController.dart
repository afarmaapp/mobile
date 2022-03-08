import 'dart:io';

// import 'package:afarma/AboutUsController.dart';
import 'package:afarma/model/popularModels/AdBanner.dart';
import 'package:afarma/page/afarmaPopular/profile/ProfileController.dart';
import 'package:afarma/repository/popularRepositories/AdBannerManager.dart';
import 'package:afarma/page/PolicyPage.dart';
import 'package:afarma/service/popularServices/User.dart';
import 'package:afarma/model/popularModels/Address.dart';
// import 'package:afarma/page/afarmaPopular/MainTabController.dart';
import 'package:afarma/page/afarmaPopular/home/ProductDetailController.dart';
import 'package:afarma/model/popularModels/Medication.dart';
import 'package:afarma/repository/popularRepositories/MedicationManager.dart';
import 'package:afarma/model/popularModels/Segment.dart';
import 'package:afarma/repository/popularRepositories/SegmentManager.dart';
import 'package:afarma/model/popularModels/Version.dart';
import 'package:afarma/repository/popularRepositories/VersionManager.dart';
import 'package:afarma/service/popularServices/LocationServices.dart';
import 'package:afarma/page/afarmaPopular/home/VersionController.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_restart/flutter_restart.dart';
import 'package:url_launcher/url_launcher.dart';

String _supportNum = '+5521986952438';
String _defaultMessage =
    'Olá! Gostaria de mais informações sobre o aFarma Popular';

class HomeController extends StatefulWidget {
  HomeController(
      {required this.scrollController,
      required this.pageController,
      required this.tabIndex,
      this.onShowTabBar});

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex tabIndex;
  final VoidCallback? onShowTabBar;

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController>
    with AutomaticKeepAliveClientMixin<HomeController> {
  List<Segment> get _segments => SegmentManager().segments;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Segment> _activeSegments = [];

  List<Medication> get _meds => MedicationManager().meds;
  List<AdBanner> get _ads => AdBannerManager().ads;
  String? localVersion;

  bool isDifferent = false;

  Address _currentAddress = Address(located: false);

  final MethodChannel _channel = const MethodChannel('whatsapp');

  @override
  void initState() {
    super.initState();
    // Navigator.pushNamed(context, 'HomeAfarmaPopular');
    _fetchData();
    User.fetch();
    // checkLocationIsEnabled();
    _appVersion();
    atualizeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          toolbarHeight: 75,
          leadingWidth: 0,
          leading: Container(),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25))),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.transparent,
                // decoration: BoxDecoration(color: Colors.blue),
                child: IconButton(
                  splashRadius: 1,
                  padding: EdgeInsets.all(10),
                  iconSize: 30,
                  icon: Icon(User.instance == null
                      ? Icons.person_outline
                      : Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileController()),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 8),
                  width: MediaQuery.of(context).size.width - 100,
                  height: 60,
                  // decoration: BoxDecoration(color: Colors.orange),
                  child: Column(children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Icon(
                          Icons.location_on,
                          size: 22,
                        )),
                    Expanded(
                      child: AutoSizeText(
                        _locationText()!,
                        style: TextStyle(fontWeight: FontWeight.w100),
                        textAlign: TextAlign.center,
                        minFontSize: 15,
                        maxFontSize: 18,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ])),
              IconButton(
                splashRadius: 1,
                padding: EdgeInsets.all(10),
                iconSize: 30,
                icon: Icon(Icons.info_outline),
                tooltip: "Informações e Termos de Uso",
                onPressed: () {
                  _showInfo();
                },
              ),
            ],
            // mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        body: RefreshIndicator(
          child: Container(child: _mainBody()),
          onRefresh: () => _refreshData(),
        ),
        key: _scaffoldKey,
        floatingActionButton: Platform.isAndroid
            ? Align(
                alignment: Alignment(1, 0.7),
                child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    child: Image(
                      image: AssetImage('assets/images/whatsapp.png'),
                    ),
                    onPressed: () => _callWhatsApp()),
              )
            : Container());
  }

  // void atualizeApp() async {
  //   VersionController versionController = VersionController();
  //   await versionController.verifyVersion();
  //   bool isDifferent = versionController.isDifferent;

  //   if (isDifferent) {
  //     showDialog(
  //         builder: (context) {
  //           return AlertDialog(
  //             actions: [
  //               FlatButton(
  //                 child: Text('Sim'),
  //                 onPressed: () {
  //                   linkApp();
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //               FlatButton(
  //                 child: Text('Não'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   showDialog(
  //                       builder: (context) {
  //                         return AlertDialog(
  //                           actions: [
  //                             FlatButton(
  //                               child: Text('OK'),
  //                               onPressed: () => {Navigator.pop(context)},
  //                             )
  //                           ],
  //                           content: Text(
  //                               'Caso deseje atualizar depois clique no icone no lado superior direito.'),
  //                         );
  //                       },
  //                       context: context);
  //                 },
  //               ),
  //             ].reversed.toList(),
  //             content: Text(
  //               'Seu Aplicativo está desatualizado, deseja atualizar?',
  //               textAlign: TextAlign.center,
  //             ),
  //           );
  //         },
  //         context: context);
  //   }
  // }

  void atualizeApp() async {
    VersionController versionController = VersionController();
    await versionController.verifyVersion();
    bool isDifferent = versionController.isDifferent;

    if (isDifferent) {
      showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: false,
          context: context,
          builder: (BuildContext context) {
            return Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.red,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                      Image.asset(
                        'assets/images/logos/farmaSmallLogo.png',
                        width: MediaQuery.of(context).size.width - 250,
                        // height: 100,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Atualize o app para poder continuar usando!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white)),
                        child: const Text(
                          'Atualizar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red),
                        ),
                        onPressed: () => atualizingApp(),
                      )
                    ])));
          });
    }
  }

  void _callWhatsApp() async {
    late String url;

    if (Platform.isIOS) {
      url = 'whatsapp://send?phone=$_supportNum&text=$_defaultMessage';
    } else if (Platform.isAndroid) {
      url = 'https://wa.me/$_supportNum&text=$_defaultMessage';
    }
    if (await canLaunch(url)) {
      launch(url);
    } else {
      showDialog(
          builder: (context) {
            return AlertDialog(
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
              content: Text(
                  'Ocorreu um erro ao abrir o WhatsApp. Tente novamente mais tarde.'),
            );
          },
          context: context);
    }
  }

  String? _locationText() {
    if (_currentAddress != null) {
      if (_currentAddress.googleAddress != null &&
          !_currentAddress.googleAddress!.isBrazil()) {
        return _currentAddress.googleAddress!.country!.longName;
      }
      if (_currentAddress.street != null) {
        return _currentAddress.street;
      } else if (_currentAddress.neighborhood != null) {
        return _currentAddress.neighborhood;
      } else if (_currentAddress.city != null) {
        return _currentAddress.city;
      } else if (_currentAddress.state != null) {
        return _currentAddress.state;
      }
      return 'Brasil';
    }
    return 'Pegando localização...';
  }

  Widget _mainBody() {
    List<Medication> meds = _meds.toList();
    meds.removeWhere((element) => _activeSegments.contains(element.segment));

    return SingleChildScrollView(
      child: Column(
        children: [
          _adBanner(),
          _pharmacyImage(),
          _freeMedsImage(),
          _segmentsSelection(),
          _selectedSegments(),
          _otherProducts(),
          _products(meds),
          _appVersion()
        ],
      ),
      controller: widget.scrollController,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Future<String?> viewAppVersion() async {
    VersionController versionController = VersionController();
    await versionController.verifyVersion();
    // ignore: await_only_futures
    isDifferent = await versionController.isDifferent;

    localVersion = await VersionController.getAppVersion();
    print('Versão === $localVersion');

    if (isDifferent) {
      return localVersion;
    } else {
      return '';
    }
  }

  void linkApp() {
    showDialog(
        builder: (context) {
          return AlertDialog(
            actions: [
              FlatButton(
                child: Text('Sim'),
                onPressed: () {
                  atualizingApp();
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Não'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ].reversed.toList(),
            content: Text(
              'Seu Aplicativo está desatualizado, deseja atualizar?',
              textAlign: TextAlign.center,
            ),
          );
        },
        context: context);
  }

  void _showInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PolicyPage()));
  }

  void atualizingApp() async {
    List<Version> versionApp = await VersionManager().refreshVersions();

    VersionController.setAppVersion(
        false, '${versionApp[0].vAPP}', '${versionApp[0].id}');

    if (Platform.isAndroid) {
      launch('https://play.google.com/store/apps/details?id=etc.bda.afarma');
    } else if (Platform.isIOS) {
      launch('https://apps.apple.com/br/app/afarma-popular/id1535314750');
    }
  }

  Widget _appVersion() {
    viewAppVersion();

    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
              text: '${localVersion != null ? localVersion : ''}',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _adBanner() {
    return Padding(
      child: SingleChildScrollView(
        child: Row(
          children: _ads.map((ad) {
            return InkWell(
              child: Image.network(
                ad.imgURL!,
                height: 100,
                width: MediaQuery.of(context).size.width - 40,
              ),
              onTap: () => launch(ad.redirectURL!),
            );
          }).toList(),
        ),
        scrollDirection: Axis.horizontal,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _pharmacyImage() {
    return Image.asset(
      'assets/images/farmaciaPopular.png',
      width: MediaQuery.of(context).size.width - 40,
      height: 100,
    );
  }

  Widget _freeMedsImage() {
    return Padding(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/freeMeds.jpg')),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _segmentsSelection() {
    if (_segments == null) return Container();
    return SingleChildScrollView(
      child: Row(
        children: [SizedBox(width: 10.0)] +
            _segments
                .map((segment) =>
                    SizedBox(child: _segmentCell(segment), height: 100))
                .toList() +
            [SizedBox(width: 10.0)],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _selectedSegments() {
    List<Widget> widgets = [Container()];
    _activeSegments
        .forEach((segment) => widgets.add(_productsForSegment(segment)));
    return Column(children: widgets.reversed.toList());
  }

  Widget _otherProducts() {
    if (_activeSegments.length == 0 ||
        _activeSegments.length == _segments.length) return Container();
    return Padding(
      child: Text(
        'Outros produtos',
        style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        textAlign: TextAlign.left,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _productsForSegment(Segment segment) {
    return Column(
      children: [
        Padding(
          child: Column(
            children: [
              Text(
                'Produtos para ${segment.description}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 5.0),
              MedicationManager().sortedMeds.containsKey(segment)
                  ? Text(
                      'Arraste para o lado para ver mais ->',
                      style: TextStyle(
                          color: segment.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    )
                  : Container()
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          padding: EdgeInsets.all(20),
        ),
        _segmentProducts(segment),
        Padding(
          child: Divider(
            color: Color.fromRGBO(255, 49, 49, 1),
            /* red */
            thickness: 1,
          ),
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
        )
      ],
    );
  }

  Widget _products(List<Medication> meds) {
    if (_activeSegments.length == _segments.length) return Container();
    if (meds == null) {
      return Container(
        child: Center(
          child: Text('Carregando produtos...'),
        ),
      );
    } else if (meds.length == 0) {
      return Container(
        child: Center(
          child: Text('Não há produtos!'),
        ),
      );
    }

    List<List<Widget>> widgets = [<Widget>[]];
    meds.forEach((med) {
      Widget toAddWidget = _productCell(med);
      if (widgets.last.length == 2) {
        widgets.add(<Widget>[]);
      }
      widgets.last.add(toAddWidget);
    });

    return Padding(
      child: Column(
        children: widgets
            .map((widgetList) => Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: widgetList.first,
                        flex: 47,
                      ),
                      Spacer(flex: 6),
                      Expanded(
                        child: widgetList.length == 2
                            ? widgetList.last
                            : Container(),
                        flex: 47,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ))
            .toList(),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _segmentProducts(Segment segment) {
    if (!MedicationManager().sortedMeds.containsKey(segment)) {
      return Container(
        child: Center(
          child: Text('Carregando produtos...'),
        ),
      );
    }
    List<Medication> meds = MedicationManager().sortedMeds[segment]!;
    meds.sort((medA, medB) => medA.compareTo(medB));
    if (meds == null || meds.length == 0) {
      return Container(
        child: Center(
          child: Text(meds == null
              ? 'Carregando produtos...'
              : 'Carregando produtos...'),
        ),
        padding: EdgeInsets.all(20),
      );
    }
    List<Widget> children = [];
    meds.forEach((med) {
      children.addAll([
        SizedBox(
          child: _productCell(med),
          width: MediaQuery.of(context).size.width * 0.47,
        ),
        SizedBox(width: 10.0)
      ]);
    });
    return SingleChildScrollView(
      child: Padding(
        child: Row(
          children: children,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        padding: EdgeInsets.all(20),
      ),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _productCell(Medication med) {
    final double positionAddButton = -50.0;

    return GestureDetector(
        child: Column(
          children: [
            Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        child: Image(
                          fit: BoxFit.cover,
                          image: med.medImage(),
                        ),
                        tag: med.id!,
                      ),
                      Positioned(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 37.5, vertical: 8),
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                  text: 'ADICIONAR')),
                          decoration: BoxDecoration(
                              color: Colors.cyan,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        top: MediaQuery.of(context).size.width / 3.55,
                      )
                    ],
                  )),
              decoration: BoxDecoration(
                  border: Border.all(color: med.segment!.color!, width: 4.0),
                  borderRadius: BorderRadius.circular(20)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(children: [
                AutoSizeText(
                  med.name!,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                  maxLines: 4,
                ),
                AutoSizeText(
                  med.amount!,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                ),
                AutoSizeText(
                  'Posologia: ${med.posology ?? ''}',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              ], crossAxisAlignment: CrossAxisAlignment.start),
            )
          ],
        ),
        onTap: () => _viewProductDetail(med),
        onLongPress: () => _viewProductDetail(med));
  }

  Widget _segmentCell(Segment segment) {
    return Container(
      child: ButtonTheme(
        child: RaisedButton(
          child: Text(
            segment.description!,
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          color: segment.color,
          onPressed: () {
            if (_activeSegments.contains(segment)) {
              _activeSegments.remove(segment);
            }
            _activeSegments.add(segment);
            setState(() {});
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        minWidth: MediaQuery.of(context).size.width / 4,
      ),
      padding:
          EdgeInsets.only(top: 25.0, left: 10.0, right: 10.0, bottom: 25.0),
    );
  }

  // void _showInfo() {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => AboutUsController()));
  // }

  void _viewProductDetail(Medication med) async {
    bool? resp = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailController(product: med)));
    if (resp != null && resp == true) {
      widget.pageController
          .nextPage(duration: Duration(milliseconds: 600), curve: Curves.ease);
      widget.tabIndex.nextIndex();
    }
  }

  void _showMessages() {}

  void _fetchData() {
    SegmentManager().addListener(() {
      setState(() {});
    });
    MedicationManager().addListener(() {
      setState(() {});
    });
    SegmentManager().fetchSegments().then((_) {
      setState(() {});
    });
    MedicationManager().fetchMedications().then((_) {
      List<String?> ids = [];
      MedicationManager().meds.forEach((element) {
        ids.add(element.id);
      });
      //ids.
      setState(() {});
    });
    AdBannerManager().addListener(() {
      setState(() {});
    });
    AdBannerManager().getAds().then((_) {
      setState(() {});
    });
    LocationServices.currentLocation().then((location) {
      if (location == null) {
        _currentAddress = Address(located: false);
      } else {
        _currentAddress = location.toAddress();
        if (!location.isBrazil()) {
          if (!mounted) return;
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                  actions: [
                    FlatButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.pop(context))
                  ],
                  content: Text(
                      'Parece que você atualmente não se localiza no Brasil. Para realizar pedidos será necessário usar um endereço brasileiro.'));
            },
          );
        }
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _refreshData() async {
    SegmentManager().refreshSegments().then((_) {
      setState(() {
        _activeSegments.clear();
      });
    });
    MedicationManager().refreshMedications();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    SegmentManager().removeListener(() {});
    MedicationManager().removeListener(() {});
  }
}
