import 'package:app/modules/cart/components/cart_product_card/cart_product_card.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    Key? key,
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
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      width: deviceWidth,
      height: deviceHeight,
      child: Column(
        children: [
          Text(
            'Carrinho',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w700,
              fontSize: 21,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: 6,
              itemBuilder: (context, index) => CartProductCard(),
            ),
          )
        ],
      ),
    );
  }
}
