import 'package:app/modules/home/models/product/product_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app/helper/app_colors.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.onTap,
    required this.product,
  }) : super(key: key);

  final Product product;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
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
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.network(
                  'https://images.afarma.app.br/afarmaimg/${widget.product.ean}.jpg',
                  errorBuilder: ((context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/afarmaGeneric.png',
                      width: deviceWidth * 0.35,
                      height: deviceWidth * 0.3,
                      fit: BoxFit.contain,
                    );
                  }),
                  width: deviceWidth * 0.35,
                  height: deviceWidth * 0.3,
                  fit: BoxFit.contain,
                ),
                AutoSizeText(
                  widget.product.nome,
                  maxLines: 2,
                  softWrap: true,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: deviceWidth * 0.09,
              height: deviceWidth * 0.09,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: AppColors.primary,
              ),
              child: Icon(
                Icons.add,
                color: AppColors.white,
                size: deviceWidth * 0.065,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
