// import 'package:afarma/page/afarmaPopular/MainTabController.dart';
import 'package:afarma/shared/MainTabController.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class WalkthroughController extends StatefulWidget {
  @override
  _WalkthroughControllerState createState() => _WalkthroughControllerState();
}

class _WalkthroughControllerState extends State<WalkthroughController> {
  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  List<String> _items = ['aa', 'afad', 'asda'];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, position) => _buildPage(position),
        itemCount: _items.length,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget _buildPage(int index) {
    return Container(
      child: Column(
        children: [
          Spacer(flex: 6),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logos/farmaSmallLogo.png',
                  color: Colors.white,
                  height: 60,
                  width: 60,
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                'Vamos comprar, \nCompre Saúde',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 15.0),
              Text(
                'Example text\nExample text\nExample text',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w300),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          Spacer(flex: 2),
          DotsIndicator(
            dotsCount: _items.length,
            position: double.parse(index.toString()),
            decorator:
                DotsDecorator(activeColor: Colors.white, color: Colors.grey),
          ),
          Spacer(
            flex: 3,
          ),
          IconButton(
            icon: Icon(Icons.next_week),
            onPressed: () => _nextPage(),
          )
        ],
      ),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/images/backgrounds/walkthroughBackground.png'),
              fit: BoxFit.fill)),
      padding: EdgeInsets.only(left: 60.0, right: 60.0),
    );
  }

  void _nextPage() {
    if ((_pageIndex + 1) != _items.length) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 600), curve: Curves.ease);
      _pageIndex++;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainTabController(), fullscreenDialog: true),
      );
    }
  }

  void _earlierPage() {
    if (_pageIndex > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 600), curve: Curves.ease);
      _pageIndex--;
    }
  }
}
