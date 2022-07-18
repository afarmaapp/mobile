import 'package:app/helper/app_colors.dart';
import 'package:app/modules/cart/components/cart_product_card/cart_product_card.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/modules/login/register_page.dart';
import 'package:app/modules/profile/profile_page.dart';
import 'package:app/shared/components/button_widget/button_widget.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:app/shared/components/social_button_widget/social_button_widget.dart';
import 'package:app/shared/components/text_field/text_field_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final controller = GetIt.I.get<LoginController>();

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFieldWidget(
          label: 'Email',
          onChanged: controller.changeEmail,
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          label: 'Senha',
          onChanged: controller.changePassword,
        ),
        const SizedBox(
          height: 15,
        ),
        ButtonWidget(
          label: 'Entrar',
          onTap: () async {
            dynamic resp = await controller.loginWithEmailAndPassword();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarWidget().alert(resp),
            );
            if (resp["error"] != null && !resp["error"]) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            }
          },
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ainda não tem uma conta? ',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              child: Text(
                'Cadastre-se',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color.fromARGB(255, 110, 190, 255),
                    shadows: [
                      const Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 3,
                      )
                    ]),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          'ou',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColors.white,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SocialButtonWidget(
          type: SocialButtonType.none,
          label: 'Voltar',
          onTap: () async {
            controller.localLogin = false;
          },
        ),
      ],
    );
  }
}
