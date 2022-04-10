import 'package:app/helper/app_colors.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/modules/login/login_widget.dart';
import 'package:app/modules/profile/profile_page.dart';
import 'package:app/shared/components/button_widget/button_widget.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:app/shared/components/social_button_widget/social_button_widget.dart';
import 'package:app/shared/components/text_field/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = GetIt.I.get<LoginController>();

  @override
  void initState() {
    controller.localLogin = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Observer(
        builder: (_) {
          return Container(
            width: deviceWidth,
            height: deviceHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/backgrounds/loginRedBackground.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo-white.png',
                  width: deviceWidth * 0.45,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Bem vindo ao aFarma',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                controller.localLogin
                    ? const LoginWidget()
                    : Column(
                        children: [
                          // SocialButtonWidget(
                          //   type: SocialButtonType.google,
                          //   label: 'Continuar com Google',
                          //   loading: controller.googleAuthState ==
                          //       GoogleAuthState.loading,
                          //   onTap: () async {
                          //     dynamic resp = await controller.googleSignIn();

                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBarWidget().alert(resp),
                          //     );
                          //     if (resp["error"] != null && !resp["error"]) {
                          //       Navigator.pushReplacement(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => const ProfilePage(),
                          //         ),
                          //       );
                          //     }
                          //   },
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          SocialButtonWidget(
                            type: SocialButtonType.none,
                            label: 'Continuar com Email',
                            onTap: controller.toogleLocalLogin,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'ou',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SocialButtonWidget(
                            type: SocialButtonType.none,
                            label: 'Entrar como Convidado',
                            onTap: () async {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainTabController(),
                                ),
                              );
                            },
                          ),
                        ],
                      )
              ],
            ),
          );
        },
      ),
    );
  }
}
