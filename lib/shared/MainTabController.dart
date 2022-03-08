// import 'package:afarma/FloatingNavBar/FloatingNavbar.dart';
// import 'package:afarma/FloatingNavBar/FloatingNavbarItem.dart';
// import 'package:afarma/Home/Cart.dart';
// import 'package:afarma/Home/Controllers/CartController.dart';
// import 'package:afarma/Home/Controllers/HomeController.dart';
// import 'package:afarma/Home/Controllers/PurchasesController.dart';
// import 'package:afarma/Home/Controllers/SettingsController.dart';
import 'package:afarma/component/floating_navbar/FloatingNavbar.dart';
import 'package:afarma/component/floating_navbar/FloatingNavbarItem.dart';
import 'package:afarma/helper/AppColors.dart';
import 'package:afarma/model/Cart.dart';
import 'package:afarma/page/HomePage.dart';
import 'package:afarma/page/afarmaPopular/AfarmaPage.dart';
import 'package:afarma/page/afarmaPopular/cart/CartController.dart';
import 'package:afarma/page/afarmaPopular/home/HomeController.dart';
import 'package:afarma/page/afarmaPopular/profile/ProfileController.dart';
import 'package:afarma/page/afarmaPopular/purchase/PurchasesController.dart';
import 'package:afarma/page/cart/CartPage.dart';
import 'package:afarma/page/promos/PromosPage.dart';
import 'package:afarma/page/purchases/PurchasesPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TabIndex extends ChangeNotifier {
  int index = 0;

  void newIndex(int idx) {
    index = idx;
    notifyListeners();
  }

  void nextIndex() {
    index++;
    notifyListeners();
  }

  void earlierIndex() {
    index--;
    notifyListeners();
  }
}

class MainTabController extends StatefulWidget {
  MainTabController({this.isAfarmaPopular = false});

  bool isAfarmaPopular;

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  final TabIndex _index = TabIndex();

  List<FloatingNavbarItem> _navBarItems = [
    FloatingNavbarItem(icon: Icons.home, title: 'Home'),
    FloatingNavbarItem(icon: Icons.shopping_basket, title: 'Cesta'),
    FloatingNavbarItem(image: Image.asset('assets/images/logo-popular.png')),
    FloatingNavbarItem(icon: Icons.format_align_center, title: 'Pedidos'),
    FloatingNavbarItem(icon: Icons.monetization_on, title: 'Promoção')
  ];

  List<FloatingNavbarItem> _navBarItemsAfarma = [
    FloatingNavbarItem(icon: Icons.home, title: 'Home'),
    FloatingNavbarItem(icon: Icons.shopping_basket, title: 'Cesta'),
    FloatingNavbarItem(image: Image.asset('assets/images/logo-afarma.png')),
    FloatingNavbarItem(icon: Icons.format_align_center, title: 'Pedidos'),
    FloatingNavbarItem(icon: Icons.person, title: 'Perfil')
  ];

  List<Widget> _controllers = [];

  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  ScrollController _homeScrollController = ScrollController();
  ScrollController _cartScrollController = ScrollController();
  ScrollController _afarmaScrollController = ScrollController();
  ScrollController _purchasesScrollController = ScrollController();
  ScrollController _promosScrollController = ScrollController();

  bool _showTabBar = true;

  @override
  void initState() {
    super.initState();
    _index.addListener(() {
      _showBars();
      setState(() {});
    });

    _buildControllers();

    Cart().addListener(() {
      if (mounted) {
        FloatingNavbarItem navbarItem =
            _navBarItems.firstWhere((element) => element.title == 'Cesta');
        navbarItem.count = Cart().meds.length;
        setState(() {});
      }
    });

    _homeScrollController
        .addListener(() => _handleScrollController(_homeScrollController));
    _cartScrollController
        .addListener(() => _handleScrollController(_cartScrollController));
    _afarmaScrollController
        .addListener(() => _handleScrollController(_afarmaScrollController));
    _purchasesScrollController
        .addListener(() => _handleScrollController(_purchasesScrollController));
    _promosScrollController
        .addListener(() => _handleScrollController(_promosScrollController));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
        body: PageView(
          children: _controllers,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: _floatingTabBar(),
        extendBody: true,
      ),
      length: _controllers.length,
      initialIndex: 0,
    );
  }

  Widget _floatingTabBar() {
    return AnimatedOpacity(
      child: IgnorePointer(
        child: FloatingNavbar(
          backgroundColor: Colors.white,
          borderRadius: 50,
          currentIndex: _index.index,
          displayTitle: true,
          items: widget.isAfarmaPopular ? _navBarItemsAfarma : _navBarItems,
          // onTap: (_showTabBar ? _changePage : null),
          onTap: _changePage,
          selectedItemColor: AppColors.selected, //AppColors.primary,
          /* red */
          unselectedItemColor: Colors.grey,
        ),
        ignoring: !_showTabBar,
      ),
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 400),
      opacity: (_showTabBar ? 1.0 : 0.0),
    );
  }

  void _changePage(int newIndex) {
    _index.index = newIndex;
    if (newIndex == 2) {
      if (widget.isAfarmaPopular) {
        Navigator.pushNamed(context, 'Home');
      } else {
        Navigator.pushNamed(context, 'HomeAfarmaPopular');
      }
    } else {
      _pageController.jumpToPage(_index.index);
    }
    setState(() {});
  }

  void _buildControllers() {
    if (_controllers != null && _controllers.length != 0) return;
    setState(() {
      if (widget.isAfarmaPopular) {
        _controllers.addAll([
          HomeController(
            scrollController: _homeScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          CartController(
            scrollController: _cartScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          HomePage(
            scrollController: _homeScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          PurchasesController(
            scrollController: _purchasesScrollController,
          ),
          ProfileController()
        ]);
      } else {
        _controllers.addAll([
          HomePage(
            scrollController: _homeScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          CartPage(
            scrollController: _cartScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          HomeController(
            scrollController: _afarmaScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          PurchasesPage(
            scrollController: _purchasesScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
          PromosPage(
            scrollController: _promosScrollController,
            pageController: _pageController,
            tabIndex: _index,
            onShowTabBar: _showBars,
          ),
        ]);
      }
    });
  }

  void _showBars() {
    setState(() {
      _showTabBar = true;
    });
  }

  void _hideBars() {
    setState(() {
      _showTabBar = false;
    });
  }

  void _handleScrollController(ScrollController sc) {
    switch (sc.position.userScrollDirection) {
      case ScrollDirection.reverse:
        return _hideBars();
      case ScrollDirection.forward:
        return _showBars();
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _index.removeListener(() {});
    _homeScrollController.removeListener(() {});
    _cartScrollController.removeListener(() {});
    _purchasesScrollController.removeListener(() {});
  }
}
