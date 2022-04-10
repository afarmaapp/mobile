import 'package:app/helper/app_colors.dart';
import 'package:app/modules/cart/components/cart_product_card/cart_product_card.dart';
import 'package:app/modules/cotation/cotation_page.dart';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
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
  final cotationController = GetIt.I.get<CotationController>();

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: deviceWidth,
      height: deviceHeight,
      child: Observer(builder: (_) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Text(
                  'Cesta',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                  ),
                ),
                Expanded(
                  child: cotationController.products.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: cotationController.products.length,
                          itemBuilder: (context, index) => index !=
                                  cotationController.products.length - 1
                              ? CartProductCard(
                                  product: cotationController.products[index],
                                )
                              : Column(
                                  children: [
                                    CartProductCard(
                                      product:
                                          cotationController.products[index],
                                    ),
                                    const SizedBox(
                                      height: 210,
                                    ),
                                  ],
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/emptyCart.png',
                              width: deviceWidth * 0.9,
                            ),
                            SizedBox(
                              height: deviceHeight * 0.16,
                            ),
                          ],
                        ),
                )
              ],
            ),
            cotationController.products.isNotEmpty
                ? Positioned(
                    bottom: deviceHeight * 0.17,
                    child: Material(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          final resp = await cotationController.goToCotation();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBarWidget().alert(resp),
                          );
                          if (resp["error"] != null && !resp["error"]) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CotationPage(),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: deviceWidth * 0.9,
                          height: deviceWidth * 0.135,
                          alignment: Alignment.center,
                          child: cotationController.cotationState ==
                                  CotationState.loading
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Cotar',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    fontSize: 17,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      }),
    );
  }
}
