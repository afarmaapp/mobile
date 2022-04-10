import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/modules/login/login_page.dart';
import 'package:app/shared/controllers/user/user_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app/helper/app_colors.dart';
import 'package:intl/intl.dart';

class CotationDetails extends StatefulWidget {
  const CotationDetails({
    Key? key,
  }) : super(key: key);

  @override
  State<CotationDetails> createState() => _CotationDetailsState();
}

class _CotationDetailsState extends State<CotationDetails> {
  final controller = GetIt.I.get<CotationController>();
  final userController = GetIt.I.get<UserController>();

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Observer(
      builder: (_) => AnimatedOpacity(
        opacity: controller.opacity,
        duration: Duration(milliseconds: controller.durationInMilliseconds),
        child: controller.selectedProduct != null
            ? AnimatedContainer(
                duration:
                    Duration(milliseconds: controller.durationInMilliseconds),
                height: controller.height,
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                color: AppColors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/afarmaGeneric.png',
                          width: deviceWidth * 0.3,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              AutoSizeText(
                                controller.selectedProduct!.nome,
                                maxLines: 2,
                                softWrap: true,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      controller.changeQuantity(
                                          ChangeQuantity.remove);
                                    },
                                    child: Container(
                                      width: deviceWidth * 0.2,
                                      height: deviceWidth * 0.08,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 6,
                                            color:
                                                AppColors.grey.withOpacity(0.4),
                                          )
                                        ],
                                      ),
                                      child: Icon(Icons.remove),
                                    ),
                                  ),
                                  AutoSizeText(
                                    controller.selectedProductQnt.toString(),
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller
                                          .changeQuantity(ChangeQuantity.add);
                                    },
                                    child: Container(
                                      width: deviceWidth * 0.2,
                                      height: deviceWidth * 0.08,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 6,
                                            color:
                                                AppColors.grey.withOpacity(0.4),
                                          )
                                        ],
                                      ),
                                      child: Icon(Icons.add),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        controller.selectedProduct!.valorRaia != null &&
                                controller.selectedProduct!.valorRaia! >
                                    controller.selectedProduct!.valor
                            ? Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      'assets/images/logo-raia.png',
                                      width: deviceWidth * 0.2,
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'pt_BR', symbol: 'R\$')
                                          .format(
                                        controller.selectedProduct!.valorRaia,
                                      ),
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/logo-red.png',
                                width: deviceWidth * 0.2,
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'pt_BR', symbol: 'R\$')
                                    .format(
                                  controller.selectedProduct!.valor,
                                ),
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              controller.addProduct();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: deviceWidth * 0.9,
                              height: deviceWidth * 0.135,
                              alignment: Alignment.center,
                              child: Text(
                                'Adicionar',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.toogleShowCotationDetails(0, null);
                          },
                          child: Container(
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.close,
                                ),
                                Text(
                                  'Fechar',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }
}
