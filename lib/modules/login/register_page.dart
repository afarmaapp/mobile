import 'package:app/helper/app_colors.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:app/modules/login/helper/register_details.dart';
import 'package:app/modules/login/login_widget.dart';
import 'package:app/modules/profile/profile_page.dart';
import 'package:app/shared/components/button_widget/button_widget.dart';
import 'package:app/shared/components/date_picker/date_picker.dart';
import 'package:app/shared/components/main_tab_controller.dart';
import 'package:app/shared/components/masked_text_field/masked_text_field_widget.dart';
import 'package:app/shared/components/snack_bar_widget/snack_bar_widget.dart';
import 'package:app/shared/components/social_button_widget/social_button_widget.dart';
import 'package:app/shared/components/text_field/text_field_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final controller = GetIt.I.get<LoginController>();
  RegisterDetails registerDetails = RegisterDetails();

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
                  'Faça seu cadastro!',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFieldWidget(
                  label: 'Nome',
                  onChanged: (val) {
                    registerDetails.nome = val;
                    setState(() {});
                  },
                  error: controller.showErrors &&
                          (registerDetails.nome!.isEmpty ||
                              registerDetails.nome == null)
                      ? 'Esse campo é obrigatório!'
                      : null,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaskedTextFieldWidget(
                  label: 'CPF',
                  mask: '###.###.###-##',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    registerDetails.cpf = val;
                    setState(() {});
                  },
                  error: controller.showErrors &&
                          (registerDetails.cpf!.isEmpty ||
                              registerDetails.cpf == null)
                      ? 'Esse campo é obrigatório!'
                      : null,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.co_present_outlined,
                      size: 32,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  label: 'Email',
                  onChanged: (val) {
                    registerDetails.email = val;
                    setState(() {});
                  },
                  error: controller.showErrors &&
                          (registerDetails.email!.isEmpty ||
                              registerDetails.email == null)
                      ? 'Esse campo é obrigatório!'
                      : null,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.email,
                      size: 32,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  label: 'Senha',
                  onChanged: (val) {
                    registerDetails.password = val;
                    setState(() {});
                  },
                  error: controller.showErrors &&
                          (registerDetails.password!.isEmpty ||
                              registerDetails.password == null)
                      ? 'Esse campo é obrigatório!'
                      : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                MaskedTextFieldWidget(
                  label: 'Telefone',
                  mask: '(##) # ####-####',
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    registerDetails.telefone = val;
                    setState(() {});
                  },
                  error: controller.showErrors &&
                          (registerDetails.telefone!.isEmpty ||
                              registerDetails.telefone == null)
                      ? 'Esse campo é obrigatório!'
                      : null,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.phone,
                      size: 32,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: deviceWidth * 0.8,
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.secondary,
                        value: registerDetails.aceiteTermo,
                        onChanged: (val) {
                          registerDetails.aceiteTermo = val!;
                          setState(() {});
                        },
                      ),
                      AutoSizeText(
                        'Aceito os termos e condições do aFarma!',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ButtonWidget(
                  label: 'Cadastrar',
                  onTap: () async {
                    if (registerDetails.checkIsCompleted()) {
                      dynamic resp = await controller.signUp(registerDetails);

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
                    } else {
                      controller.toogleShowErrors();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBarWidget().alert({
                          "error": true,
                          "msg": "Todos os campos são obrigatórios!"
                        }),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
