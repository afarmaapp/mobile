import 'dart:io';

import 'package:app/helper/app_colors.dart';
import 'package:app/helper/config.dart';
import 'package:app/helper/connector.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:app/shared/controllers/user/user_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller = GetIt.I.get<UserController>();
  final loginController = GetIt.I.get<LoginController>();
  final c = Connector(baseURL: DefaultURL.apiURL(), baseURI: DefaultURI.afarma);

  cpfFormatter(String cpf) {
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  telFormatter(String tel) {
    return '(${tel.substring(0, 2)}) ${tel.substring(2, 3)} ${tel.substring(3, 7)}-${tel.substring(7, 11)}';
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainTabController(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        elevation: 0,
        title: Text(
          'Perfil',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w900,
            fontSize: 21,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await c.logout();
              setState(() {});
              if (Platform.isAndroid) {
                Restart.restartApp();
                Navigator.pop(context);
              } else {
                Restart.restartApp();
                Navigator.pop(context);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBarWidget().alert(
                    {"error": false, "msg": "Você deslogou com Sucesso!"}),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainTabController(),
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Observer(
        builder: (_) => Container(
          width: deviceWidth,
          height: deviceHeight,
          padding: EdgeInsets.only(top: deviceHeight * 0.12),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/loginRedBackground.png',
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: controller.user != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: deviceWidth * 0.45,
                      height: deviceWidth * 0.45,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: deviceWidth * 0.43,
                        height: deviceWidth * 0.43,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        alignment: Alignment.center,
                        clipBehavior: Clip.antiAlias,
                        child: loginController.photoUrlGoogle.isNotEmpty
                            ? Image.network(
                                loginController.photoUrlGoogle,
                                width: deviceWidth * 0.43,
                                height: deviceWidth * 0.43,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                color: AppColors.white,
                                size: deviceWidth * 0.3,
                              ),
                      ),
                    ),
                    Container(
                      width: deviceWidth * 0.9,
                      height: deviceHeight * 0.28,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText.rich(
                            TextSpan(
                              text: 'Usuário\n',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.user!.nome,
                                  style: GoogleFonts.roboto(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AutoSizeText.rich(
                            TextSpan(
                              text: 'E-mail\n',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.user!.email,
                                  style: GoogleFonts.roboto(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AutoSizeText.rich(
                            TextSpan(
                              text: 'Telefone\n',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.user!.telefone != null
                                      ? controller.user!.telefone!.contains('(')
                                          ? controller.user!.telefone!
                                          : telFormatter(
                                              controller.user!.telefone!)
                                      : 'Não informado',
                                  style: GoogleFonts.roboto(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AutoSizeText.rich(
                            TextSpan(
                              text: 'CPF\n',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.user!.cpf != null
                                      ? controller.user!.cpf!.contains('.')
                                          ? controller.user!.cpf!
                                          : cpfFormatter(controller.user!.cpf!)
                                      : 'Não informado',
                                  style: GoogleFonts.roboto(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
