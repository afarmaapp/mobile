import 'package:afarma/shared/MainTabController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AfarmaPage extends StatelessWidget {
  AfarmaPage(
      {required this.scrollController,
      required this.pageController,
      this.tabIndex,
      required this.onShowTabBar});

  final ScrollController scrollController;
  final PageController pageController;
  final TabIndex? tabIndex;
  final VoidCallback onShowTabBar;

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
          'aFarma Popular',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 70),
          width: 250,
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo-afarma-popular.png',
                // width: MediaQuery.of(context).size.width - 50,
                height: 200,
              ),
              SizedBox(height: 30.0),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Página descritiva da aFarma Popular e link para download do App",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
