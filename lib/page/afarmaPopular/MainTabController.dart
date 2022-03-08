// import 'package:afarma/page/afarmaPopular/cart/CartController.dart';
// import 'package:afarma/page/afarmaPopular/home/HomeController.dart';
// import 'package:afarma/page/afarmaPopular/profile/ProfileController.dart';
// import 'package:afarma/page/afarmaPopular/purchase/PurchasesController.dart';
// import 'package:afarma/repository/popularRepositories/Cart.dart';
// import 'package:afarma/service/popularServices/FloatingNavBar/FloatingNavbar.dart';
// import 'package:afarma/service/popularServices/FloatingNavBar/FloatingNavbarItem.dart';
// import 'package:collection/collection.dart' show IterableExtension;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:url_launcher/url_launcher.dart';

// GlobalKey floatingBarKey = GlobalKey();

// class TabIndex extends ChangeNotifier {
//   int oldIndex = 0;
//   int index = 0;

//   void newIndex(int idx) {
//     oldIndex = index;
//     index = idx;
//     notifyListeners();
//   }

//   int nextIndex() {
//     oldIndex = index;
//     index++;
//     notifyListeners();
//     return index;
//   }

//   int earlierIndex() {
//     oldIndex = index;
//     index--;
//     notifyListeners();
//     return index;
//   }
// }

// class MainTabController extends StatefulWidget {
//   @override
//   _MainTabControllerState createState() => _MainTabControllerState();
// }

// class _MainTabControllerState extends State<MainTabController> {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   final TabIndex _index = TabIndex();
//   List<FloatingNavbarItem> _navBarItems = [
//     FloatingNavbarItem(icon: Icons.home, title: 'Home'),
//     FloatingNavbarItem(icon: Icons.shopping_basket, title: 'Cesta'),
//     FloatingNavbarItem(icon: Icons.format_align_center, title: 'Pedidos'),
//     FloatingNavbarItem(icon: Icons.person, title: 'Perfil')
//   ];
//   List<Widget> _controllers = [];

//   PageController _pageController =
//       PageController(initialPage: 0, keepPage: true);
//   ScrollController _homeScrollController = ScrollController();
//   ScrollController _cartScrollController = ScrollController();
//   ScrollController _purchasesScrollController = ScrollController();

//   bool _showTabBar = true;

//   @override
//   void initState() {
//     super.initState();
//     _index.addListener(() {
//       _showBars();
//       setState(() {});
//     });

//     Cart().addListener(() {
//       FloatingNavbarItem? navbarItem =
//           _navBarItems.firstWhereOrNull((element) => element.title == 'Cesta');
//       if (navbarItem != null) {
//         navbarItem.count = Cart().meds!.length;
//         setState(() {});
//       }
//     });
//     _buildControllers();
//     _homeScrollController
//         .addListener(() => _handleScrollController(_homeScrollController));
//     _cartScrollController
//         .addListener(() => _handleScrollController(_cartScrollController));
//     _purchasesScrollController
//         .addListener(() => _handleScrollController(_purchasesScrollController));
//     /*
//     _firebaseMessaging.configure(
//       onLaunch: (_launch) {

//       },
//       onResume: (resume) {

//       },
//       onMessage: (message) { 
        
//       },
//     );
//     */
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       child: Scaffold(
//         body: PageView(
//           children: _controllers,
//           controller: _pageController,
//           physics: NeverScrollableScrollPhysics(),
//           onPageChanged: (pg) {
//             _index.newIndex(pg);
//           },
//         ),
//         bottomNavigationBar: _floatingTabBar(),
//         extendBody: true,
//       ),
//       length: _controllers.length,
//       initialIndex: 0,
//     );
//   }

//   Widget _floatingTabBar() {
//     return AnimatedOpacity(
//       child: IgnorePointer(
//         child: FloatingNavbar(
//           backgroundColor: Colors.white,
//           borderRadius: 30,
//           currentIndex: _index.index,
//           displayTitle: true,
//           items: _navBarItems,
//           key: floatingBarKey,
//           onTap: (_showTabBar ? _changePage : null),
//           selectedItemColor: Color.fromRGBO(255, 49, 49, 1),
//           /* red */
//           unselectedItemColor: Colors.grey,
//         ),
//         ignoring: !_showTabBar,
//       ),
//       curve: Curves.easeInOut,
//       duration: Duration(milliseconds: 400),
//       opacity: (_showTabBar ? 1.0 : 0.0),
//     );
//   }

//   void _changePage(int newIndex) {
//     _index.index = newIndex;
//     _pageController.jumpToPage(_index.index);
//     setState(() {});
//   }

//   void _buildControllers() {
//     if (_controllers != null && _controllers.length != 0) return;
//     setState(() {
//       _controllers.addAll([
//         HomeController(
//             scrollController: _homeScrollController,
//             pageController: _pageController,
//             tabIndex: _index),
//         CartController(
//             scrollController: _cartScrollController,
//             pageController: _pageController,
//             tabIndex: _index,
//             onShowTabBar: _showBars),
//         PurchasesController(scrollController: _purchasesScrollController),
//         ProfileController(pageController: _pageController, tabIndex: _index)
//       ]);
//     });
//   }

//   void _showBars() {
//     setState(() {
//       _showTabBar = true;
//     });
//   }

//   void _hideBars() {
//     setState(() {
//       _showTabBar = false;
//     });
//   }

//   void _handleScrollController(ScrollController sc) {
//     switch (sc.position.userScrollDirection) {
//       case ScrollDirection.reverse:
//         return _hideBars();
//       case ScrollDirection.forward:
//         return _showBars();
//       default:
//         break;
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _index.removeListener(() {});
//     _homeScrollController.removeListener(() {});
//     _cartScrollController.removeListener(() {});
//     _purchasesScrollController.removeListener(() {});
//   }
// }
