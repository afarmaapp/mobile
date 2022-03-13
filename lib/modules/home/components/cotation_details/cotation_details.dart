import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller.dart/cotation_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app/helper/app_colors.dart';

class CotationDetails extends StatefulWidget {
  const CotationDetails({
    Key? key,
  }) : super(key: key);

  @override
  State<CotationDetails> createState() => _CotationDetailsState();
}

class _CotationDetailsState extends State<CotationDetails> {
  final controller = GetIt.I.get<CotationController>();

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Observer(
      builder: (_) => AnimatedOpacity(
        opacity: controller.opacity,
        duration: Duration(milliseconds: controller.durationInMilliseconds),
        child: AnimatedContainer(
          duration: Duration(milliseconds: controller.durationInMilliseconds),
          height: controller.height,
          color: AppColors.white,
          child: Column(
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
                          'Lorem Ipsum Dolor atsu met aboa not ficou',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: deviceWidth * 0.2,
                              height: deviceWidth * 0.08,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: AppColors.grey.withOpacity(0.4),
                                  )
                                ],
                              ),
                              child: Icon(Icons.remove),
                            ),
                            AutoSizeText(
                              '1',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              width: deviceWidth * 0.2,
                              height: deviceWidth * 0.08,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: AppColors.grey.withOpacity(0.4),
                                  )
                                ],
                              ),
                              child: Icon(Icons.add),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: List.generate(
                  2,
                  (index) => Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo-red.png',
                          width: deviceWidth * 0.2,
                        ),
                        Text(
                          'R\$ 1.000,00',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: deviceWidth * 0.9,
                height: deviceWidth * 0.135,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: AppColors.grey.withOpacity(0.4),
                    )
                  ],
                ),
                child: Text(
                  'Adicionar',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 17,
                  ),
                ),
              ),
              Container(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
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
            ],
          ),
        ),
      ),
    );
  }
}
