import 'package:app/helper/app_colors.dart';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/modules/home/components/cotation_details/cotation_details.dart';
import 'package:app/modules/home/components/product_card/product_card.dart';
import 'package:app/modules/home/controllers/product/product_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app/shared/components/main_tab_controller.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cotationController = GetIt.I.get<CotationController>();
  final productController = GetIt.I.get<ProductController>();

  @override
  void initState() {
    productController.getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      width: deviceWidth,
      height: deviceHeight,
      child: Column(
        children: [
          CotationDetails(),
          const SizedBox(height: 10),
          Container(
            width: deviceWidth * 0.9,
            height: deviceHeight * 0.07,
            margin: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: AppColors.grey.withOpacity(0.4),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(FeatherIcons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    onChanged: (val) {
                      productController.changeFilter(val);
                      productController.getProducts();
                    },
                  ),
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) {
              return Expanded(
                child: productController.productsState != ProductState.loading
                    ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        padding: EdgeInsets.only(
                          right: deviceWidth * 0.05,
                          left: deviceWidth * 0.05,
                          top: deviceWidth * 0.035,
                          bottom: deviceHeight * 0.19,
                        ),
                        children: List.generate(
                          productController.products.length,
                          (index) => ProductCard(
                            product: productController.products[index],
                            onTap: () {
                              if (cotationController.selectedProduct == null ||
                                  cotationController.selectedProduct ==
                                      productController.products[index]) {
                                cotationController.toogleShowCotationDetails(
                                  MediaQuery.of(context).size.height * 0.32,
                                  productController.products[index],
                                );
                              } else {
                                cotationController.changeProduct(
                                    productController.products[index]);
                              }
                            },
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
