import 'package:app/helper/app_colors.dart';
import 'package:app/modules/cart/cart_page.dart';
import 'package:app/modules/home/home_page.dart';
import 'package:app/shared/components/floating_navbar/floating_navbar.dart';
import 'package:app/shared/components/floating_navbar/floating_navbar_item.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

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
  MainTabController({Key? key, this.isAfarmaPopular = false}) : super(key: key);

  bool isAfarmaPopular;

  @override
  _MainTabControllerState createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  final TabIndex _index = TabIndex();

  final List<FloatingNavbarItem> _navBarItems = [
    FloatingNavbarItem(icon: Icons.home, title: 'Home'),
    FloatingNavbarItem(icon: Icons.shopping_basket, title: 'Cesta'),
  ];

  final List<Widget> _controllers = [];

  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _cartScrollController = ScrollController();

  bool _showTabBar = true;

  @override
  void initState() {
    super.initState();
    _index.addListener(() {
      _showBars();
      setState(() {});
    });

    _buildControllers();

    // Cart().addListener(() {
    //   if (mounted) {
    //     FloatingNavbarItem navbarItem =
    //         _navBarItems.firstWhere((element) => element.title == 'Cesta');
    //     navbarItem.count = Cart().meds.length;
    //     setState(() {});
    //   }
    // });

    _homeScrollController
        .addListener(() => _handleScrollController(_homeScrollController));
    _cartScrollController
        .addListener(() => _handleScrollController(_cartScrollController));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: GestureDetector(
            onTap: () {
              _pageController.jumpToPage(0);
              _index.index = 0;
              setState(() {});
            },
            child: Image.asset(
              'assets/images/logo-red.png',
              width: MediaQuery.of(context).size.width * 0.24,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                FeatherIcons.user,
                color: AppColors.grey,
              ),
            )
          ],
        ),
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
          items: _navBarItems,
          onTap: _changePage,
          selectedItemColor: AppColors.selected,
          unselectedItemColor: Colors.grey,
        ),
        ignoring: !_showTabBar,
      ),
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 400),
      opacity: (_showTabBar ? 1.0 : 0.0),
    );
  }

  void _changePage(int newIndex) {
    _index.index = newIndex;
    _pageController.jumpToPage(_index.index);
    setState(() {});
  }

  void _buildControllers() {
    if (_controllers != null && _controllers.length != 0) return;
    setState(() {
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
      ]);
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
  }
}
