import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Address.dart';
import 'package:afarma/model/Department.dart';
import 'package:afarma/model/Banner.dart' as banner;
import 'package:afarma/model/User.dart';
import 'package:afarma/model/Version.dart';
import 'package:afarma/page/PolicyPage.dart';
import 'package:afarma/page/VersionPage.dart';
import 'package:afarma/repository/BannerRepository.dart';
import 'package:afarma/repository/DepartmentRepository.dart';
import 'package:afarma/repository/VersionRepository.dart';
import 'package:afarma/service/LocationServices.dart';
import 'package:afarma/service/LoggedInNotifierService.dart';
import 'package:afarma/service/SearchingNotifierService.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'search/SearchPage.dart';
import 'profile/ProfilePage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {required this.scrollController,
      required this.pageController,
      this.tabIndex,
      required this.onShowTabBar});

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex? tabIndex;
  final VoidCallback onShowTabBar;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Department> get _departments => DepartmentRepository().departments;
  List<banner.Banner> get _banners => BannerRepository().banners;

  Address _currentAddress = Address(located: false);

  TextEditingController _searchController = TextEditingController();

  double headerHeight = 110;

  bool isSearch = false;
  String _supportNum = '+5521986952438';
  String _defaultMessage =
      'Olá! Gostaria de mais informações sobre o aFarma Popular';
  String? departmentId;
  String? departmentName;
  String? query;
  SearchPage? searchPage;
  GlobalKey<SearchPageState> _scaffoldKeySearchPage =
      GlobalKey<SearchPageState>();

  @override
  void initState() {
    super.initState();

    searchPage = SearchPage(
      key: _scaffoldKeySearchPage,
      scrollController: widget.scrollController,
      pageController: widget.pageController,
      tabIndex: widget.tabIndex,
    );
    _fetchData();
    atualizeApp();
  }

  double headerHeithCalculator() {
    return !this.isSearch ? headerHeight : headerHeight - 10;
  }

  @override
  Widget build(BuildContext context) {
    String placeHolderBusca = "Buscar em " +
        (this.departmentName == null
            ? "todos os produtos"
            : this.departmentName)!;

    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: AppColors.background,
        // drawerScrimColor: Colors.black,
        appBar:
            // PreferredSize(
            //   child: Container(color: Colors.red),
            //   preferredSize: Size.fromHeight(100),
            // ),
            //MyAppBar(500, 'aaaa'),
            PreferredSize(
          preferredSize: Size.fromHeight(headerHeithCalculator()),
          child: AppBar(
            // toolbarHeight: 110,
            toolbarHeight: headerHeithCalculator(),
            titleSpacing: 0,
            // primary: false,
            elevation: 5,
            leadingWidth: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            leading: Container(),
            title: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                builder: (context) => ProfilePage()),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: 30,
                      // decoration: BoxDecoration(color: Colors.orange),
                      child: _currentAddress.located
                          ? Row(children: [
                              _currentAddress.located
                                  ? Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.location_on,
                                        size: 22,
                                      ))
                                  : Container(),
                              _currentAddress.located
                                  ? AutoSizeText(
                                      _locationText()!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100),
                                      textAlign: TextAlign.center,
                                      minFontSize: 15,
                                      maxFontSize: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Container(),
                            ])
                          : IconButton(
                              splashRadius: 1,
                              padding: EdgeInsets.only(bottom: 5),
                              iconSize: 22,
                              icon: Icon(Icons.location_off),
                              tooltip: "Localização desabilitada",
                              onPressed: () {},
                            ),
                    ),
                    !this.isSearch
                        ? IconButton(
                            splashRadius: 1,
                            padding: EdgeInsets.all(10),
                            iconSize: 30,
                            icon: Icon(Icons.info_outline),
                            tooltip: "Informações e Termos de Uso",
                            onPressed: () {
                              _showInfo();
                            },
                          )
                        : IconButton(
                            splashRadius: 1,
                            padding: EdgeInsets.all(10),
                            iconSize: 30,
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => {_resetSearch()},
                          ),
                  ],
                ),
                // ),
                // !this.isSearch
                //     ? Container(
                //         width: MediaQuery.of(context).size.width,
                //         height: 20,
                //         // decoration: BoxDecoration(color: Colors.orange),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Container(
                //                 // alignment: Alignment.center,
                //                 // child: Image.asset(
                //                 //   'assets/images/logo-header.png',
                //                 //   fit: BoxFit.fitHeight,
                //                 // ),
                //                 ),
                //           ],
                //         ),
                //       )
                //     : Container(),
                Wrap(
                  spacing: 0.0, // gap between adjacent chips
                  runSpacing: 0.0, // gap between lines
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: this.isSearch
                          ? MediaQuery.of(context).size.width - 85
                          : MediaQuery.of(context).size.width - 20,
                      height: 30,
                      margin: EdgeInsets.only(
                          top: 8,
                          left: this.isSearch ? 0 : 10,
                          right: 0,
                          bottom: 10),
                      // decoration: BoxDecoration(color: Colors.orange),
                      child: TextField(
                        scrollPadding: EdgeInsets.all(0),
                        autocorrect: false,
                        controller: _searchController,
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.only(right: 40),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          hintText: placeHolderBusca,
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontWeight: FontWeight.normal),
                          // suffixIcon: IconButton(
                          //   onPressed: () {
                          //     _resetSearch();
                          //   },
                          //   icon: Icon(Icons.clear),
                          // ),
                        ),
                        enableSuggestions: false,
                        textAlign: TextAlign.center,
                        expands: false,
                        keyboardType: TextInputType.text,
                        onChanged: _onSearchChanged,
                        // onTap: () async {
                        //   setState(() {
                        //     this.isSearch = true;
                        //   });
                        // },
                        textCapitalization: TextCapitalization.none,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    this.isSearch
                        ? Container(
                            // height: 70,
                            // alignment: Alignment.bottomRight,
                            margin: EdgeInsets.only(top: 0),
                            // padding: EdgeInsets.only(: 5),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                // primary: Colors.orange,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(0),
                                onPrimary: Colors.white,
                              ),
                              autofocus: false,
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                _resetSearch();
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
        // floatingActionButton: Platform.isAndroid
        //     ? Align(
        //         alignment: Alignment(1, 0.7),
        //         child: FloatingActionButton(
        //             backgroundColor: Colors.transparent,
        //             child: Image(
        //               image: AssetImage('assets/images/whatsapp.png'),
        //             ),
        //             onPressed: () => _callWhatsApp()),
        //       )
        //     : Container(),
        extendBodyBehindAppBar: true,
        body: Container(
          margin: EdgeInsets.only(top: headerHeithCalculator()),
          child: !isSearch
              ? RefreshIndicator(
                  child: Container(child: _mainBody()),
                  onRefresh: () => _refreshData(),
                )
              : searchPage,
        ),
        key: _scaffoldKey,
      ),
    );
  }

  _resetSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.clear();
      this.isSearch = false;
      this.departmentId = null;
      this.departmentName = null;
      this.query = null;
    });
  }

  _onSearchChanged(String queryField) {
    this.query = queryField;
    _search();
  }

  _search() {
    this.query = this.query ?? '';
    this.departmentId = this.departmentId ?? '';
    if (this.query!.length == 0 && this.departmentId!.length == 0) {
      _resetSearch();
    } else {
      setState(() {
        this.isSearch = true;
      });
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      this
          ._scaffoldKeySearchPage
          .currentState!
          .search(this.query, this.departmentId, this.departmentName);
    });
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

  void _showInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PolicyPage()));
  }

  void atualizeApp() async {
    VersionPage versionPage = VersionPage();
    await versionPage.verifyVersion();
    bool isDifferent = versionPage.isDifferent;

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
                    'assets/images/logo-white-small.png',
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
                ],
              ),
            ),
          );
        },
      );
    }
  }

  String? _locationText() {
    if (_currentAddress != null) {
      if (!_currentAddress.located) {
        return '';
      }

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
    return 'Localizando...';
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      // padding: EdgeInsets.only(top: headerHeight),
      child: Column(
        children: [
          SizedBox(height: /*35*/ 25),
          _banners.length > 0
              ? _carousel()
              : Container(
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset('assets/images/logo-red.png'),
                ),
          SizedBox(height: 0),
          _pharmacyImage(),
          _departmentsList(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
      controller: widget.scrollController,
      physics: ClampingScrollPhysics(),
    );
  }

  void linkApp() {
    showDialog(
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
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
            ),
          );
        },
        context: context);
  }

  void atualizingApp() async {
    List<Version> versionApp = await VersionRepository().refreshVersions();

    VersionPage.setAppVersion(
        false, '${versionApp[0].vAPP}', '${versionApp[0].id}');

    if (Platform.isAndroid) {
      launch('https://play.google.com/store/apps/details?id=etc.bda.afarma');
    } else if (Platform.isIOS) {
      launch('https://apps.apple.com/br/app/afarma-popular/id1535314750');
    }
  }

  Widget _carousel() {
    if (_banners == null || _banners.length == 0) {
      return Container(
        child: Text("Carregando..."),
        margin: EdgeInsets.fromLTRB(10, 80, 10, 80),
      );
    }

    final List<String?> imgList = _banners.map((b) => b.urlImage).toList();

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 130,
          child: Container(
            decoration: BoxDecoration(color: Colors.white54),
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
              ),
              items: imgList
                  .map((item) => Container(
                        child: Center(
                            child: Image.network(item!,
                                fit: BoxFit.cover, width: 1000)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pharmacyImage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 5,
      child: Image.asset(
        'assets/images/home-aviso.png',
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _departmentsList() {
    if (_departments == null) return Container();

    // log("Total de apartamentos: " + _departments.length.toString());

    List<Widget> widgetsDepartments =
        _departments.map((dept) => _departmentCell(dept)).toList();

    List<Widget> widgets = [];

    widgets.add(
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Text(
          'Categorias',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    widgets.add(
      Divider(
        height: 2,
        thickness: 2,
        indent: 10,
        endIndent: 10,
        color: AppColors.primary,
      ),
    );

    // Algoritmo para colocar 2 a 2
    Widget? before;
    int counter = 1;
    for (Widget w in widgetsDepartments) {
      if (before == null) {
        if (widgetsDepartments.length == counter) {
          widgets.add(Row(
            children: [w, Container()],
            crossAxisAlignment: CrossAxisAlignment.start,
          ));
        } else {
          before = w;
        }
      } else {
        widgets.add(Row(
          children: [before, w],
          crossAxisAlignment: CrossAxisAlignment.start,
        ));
        before = null;
      }

      counter += 1;
    }

    return Column(
      children: widgets,
    );
  }

  Widget _departmentCell(Department department) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: 130,
      padding:
          EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        child: Stack(alignment: Alignment.center, children: [
          department.getImage(),
          Positioned.fill(
            left: 0.0,
            right: 0.0,
            child: ButtonTheme(
              child: ElevatedButton(
                child: AutoSizeText(
                  department.name!.toUpperCase() == 'SAUDE E BEM ESTAR'
                      ? 'SAÚDE E BEM ESTAR'
                      : department.name!.toUpperCase(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  this.departmentId = department.id;
                  this.departmentName = department.name;

                  widget.onShowTabBar();

                  _search();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  //primary: department.color!.withOpacity(0.5),
                  primary: Colors.black.withOpacity(0.2),
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.all(10),
                  onPrimary: Colors.white,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _fetchData() {
    // Listaner SEARCING
    SearchingNotifierService().addListener(() {
      if (mounted) {
        if (!SearchingNotifierService().searching) {
          _resetSearch();
        }
        setState(() {});
      }
    });

    // Listener LOGGED IN
    LoggedInNotifierService().addListener(() {
      if (mounted) setState(() {});
    });

    DepartmentRepository().addListener(() {
      setState(() {});
    });
    DepartmentRepository().fetchDepartments().then((_) {
      setState(() {});
    });

    BannerRepository().addListener(() {
      setState(() {});
    });
    BannerRepository().fetchBanners().then((_) {
      setState(() {});
    });

    // Location
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
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  actions: [
                    FlatButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.pop(context))
                  ],
                  content: Text(
                      'Parece que você atualmente não se localiza no Brasil. Para realizar pedidos será necessário usar um endereço brasileiro.'),
                ),
              );
            },
          );
        }
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _refreshData() async {
    DepartmentRepository().refreshDepartments().then((_) {
      setState(() {});
    });
    BannerRepository().refreshBanners().then((_) {
      setState(() {});
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    DepartmentRepository().removeListener(() {});
    BannerRepository().removeListener(() {});
  }
}
