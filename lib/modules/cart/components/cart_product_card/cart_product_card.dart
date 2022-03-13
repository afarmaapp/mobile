import 'package:app/helper/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartProductCard extends StatefulWidget {
  const CartProductCard({Key? key}) : super(key: key);

  @override
  State<CartProductCard> createState() => _CartProductCardState();
}

class _CartProductCardState extends State<CartProductCard> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Container(
      width: deviceWidth,
      height: deviceHeight * 0.1,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/afarmaGeneric.png',
            width: deviceWidth * 0.2,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Lorem Ipsum Dolor atsu met aboa not ficou',
                  maxLines: 2,
                  softWrap: true,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Container(
                  width: deviceWidth * 0.35,
                  height: deviceHeight * 0.036,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: AppColors.grey.withOpacity(0.3),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                offset: Offset(-3, 0),
                                color: AppColors.grey.withOpacity(0.3),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.remove,
                            color: AppColors.grey,
                            size: 21,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                offset: const Offset(3, 0),
                                color: AppColors.grey.withOpacity(0.3),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.grey,
                            size: 21,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            '1',
                            maxLines: 2,
                            softWrap: true,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
