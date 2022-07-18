import 'package:app/helper/app_colors.dart';
import 'package:app/modules/cart/models/cotation/cotation_model.dart';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class PrintResumeContainer extends StatefulWidget {
  const PrintResumeContainer({Key? key}) : super(key: key);

  @override
  State<PrintResumeContainer> createState() => _PrintResumeContainerState();
}

class _PrintResumeContainerState extends State<PrintResumeContainer> {
  final cotationController = GetIt.I.get<CotationController>();
  late Cotation afarmaCotation;

  @override
  void initState() {
    afarmaCotation = cotationController.cotations
        .firstWhere((element) => element.loja == 'AFARMA');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      width: 1080,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.grey,
                width: 1,
              ),
              color: Colors.transparent,
            ),
            width: 1080,
            height: 1920 * 0.27,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        afarmaCotation.itens.length,
                        (index) => Row(
                          children: [
                            Expanded(
                              child: Text(
                                afarmaCotation.itens[index].nome,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              '${afarmaCotation.itens[index].quantidade}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 25.0),
                            Text(
                              NumberFormat.currency(
                                      locale: 'pt_BR', symbol: 'R\$')
                                  .format(afarmaCotation.itens[index].valor),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary,
            ),
            child: Column(
              children: [
                Text(
                  "A AFARMA GARANTE SEMPRE O MENOR PREÇO",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo-red.png',
                        width: 90,
                      ),
                      Text(
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                            .format(afarmaCotation.total),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.grey[900],
                          decoration: TextDecoration.none,
                          decorationThickness: 2,
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
