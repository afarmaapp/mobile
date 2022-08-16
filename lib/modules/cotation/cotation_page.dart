import 'dart:typed_data';

import 'package:app/helper/app_colors.dart';
import 'package:app/modules/cotation/components/cotation_card/cotation_card.dart';
import 'package:app/modules/cotation/components/resume_container/print_resume_container.dart';
import 'package:app/modules/cotation/components/resume_container/resume_container.dart';
import 'package:app/modules/home/components/cotation_details/controllers/cotation_details_controller/cotation_controller.dart';
import 'package:app/shared/components/button_widget/button_widget.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class CotationPage extends StatefulWidget {
  const CotationPage({Key? key}) : super(key: key);

  @override
  State<CotationPage> createState() => _CotationPageState();
}

class _CotationPageState extends State<CotationPage> {
  final cotationController = GetIt.I.get<CotationController>();
  ScreenshotController screenshotController = ScreenshotController();

  takePrint() {
    screenshotController
        .captureFromWidget(
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/backgrounds/cotacaobg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.only(
          left: 1080 * 0.02,
          right: 1080 * 0.02,
          top: 1920 * 0.025,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Cotação',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 1920 * 0.02,
            ),
            Container(
              padding: const EdgeInsets.all(15),
              width: 1080,
              child: Column(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      cotationController.cotations.length,
                      (index) => cotationController.cotations[index].total >=
                              cotationController.cotations
                                  .where((element) => element.loja == 'AFARMA')
                                  .first
                                  .total
                          ? Container(
                              width: 100,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.grey, width: 1.0)),
                              child: Column(
                                children: [
                                  Center(
                                      child: Image.asset(
                                    'assets/images/${cotationController.cotations[index].loja == "AFARMA" ? "logo-red.png" : "logo-${cotationController.cotations[index].loja.replaceAll(' ', '-').toLowerCase()}.png"}',
                                    fit: BoxFit.fitWidth,
                                  )),
                                  const SizedBox(height: 10.0),
                                  SizedBox(
                                    width: 70,
                                    child: AutoSizeText(
                                      NumberFormat.currency(
                                              locale: 'pt_BR', symbol: 'R\$')
                                          .format(cotationController
                                              .cotations[index].total),
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ),
                    runSpacing: 15.0,
                    spacing: 15.0,
                  ),
                ],
              ),
            ),
            const PrintResumeContainer(),
          ],
        ),
      ),
    )
        .then((capturedImage) async {
      final result = await ImageGallerySaver.saveImage(
        capturedImage,
        quality: 70,
        name: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarWidget().alert({
          'error': !result['isSuccess'],
          'msg': result['isSuccess']
              ? 'Salvo na Galeria com Sucesso'
              : 'Algo deu errado tente novamente ou entre em contato conosco!',
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainTabController(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: deviceWidth,
        height: deviceHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/backgrounds/cotacaobg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(
          left: deviceWidth * 0.05,
          right: deviceWidth * 0.05,
          top: deviceWidth * 0.15,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Cotação',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              Container(
                padding: const EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        cotationController.cotations.length,
                        (index) => cotationController.cotations[index].total >=
                                cotationController.cotations
                                    .where(
                                        (element) => element.loja == 'AFARMA')
                                    .first
                                    .total
                            ? CotationCard(
                                cotation: cotationController.cotations[index],
                              )
                            : Container(),
                      ),
                      runSpacing: 15.0,
                      spacing: 15.0,
                    ),
                  ],
                ),
              ),
              const ResumeContainer(),
              ButtonWidget(
                label: 'Ir para o Whatsapp',
                color: const Color.fromARGB(255, 36, 209, 42),
                expanded: true,
                onTap: () {
                  launch(
                      'https://api.whatsapp.com/send?1=pt_br&phone=+552198695-2438&text=Ol%C3%A1,%20essa%20%C3%A9%20a%20cota%C3%A7%C3%A3o%20que%20fiz%20no%20site%20e%20gostaria%20de%20comprar:%20https://www.afarmaapp.com.br/%23/cotacao-item/${cotationController.cotations.first.id}');
                },
              ),
              SizedBox(
                height: deviceHeight * 0.01,
              ),
              ButtonWidget(
                label: 'Salvar como Imagem',
                expanded: true,
                onTap: takePrint,
              )
            ],
          ),
        ),
      ),
    );
  }
}
