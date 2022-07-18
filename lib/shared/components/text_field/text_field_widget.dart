import 'package:app/helper/app_colors.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    Key? key,
    required this.label,
    required this.onChanged,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  final String label;
  final String? error;
  final Function(String) onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  TextEditingController controller = TextEditingController();
  final loginController = GetIt.I.get<LoginController>();
  bool visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: deviceWidth * 0.8,
          height: deviceWidth * 0.125,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: widget.prefixIcon != null
              ? const EdgeInsets.only(left: 6, right: 15)
              : widget.suffixIcon != null ||
                      widget.label.toLowerCase() == 'senha'
                  ? const EdgeInsets.only(right: 4, left: 15)
                  : const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              widget.prefixIcon != null ? widget.prefixIcon! : Container(),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextField(
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: AppColors.grey,
                    decoration: TextDecoration.none,
                  ),
                  controller: controller,
                  keyboardType: widget.label.toLowerCase() == 'email'
                      ? TextInputType.emailAddress
                      : widget.label.toLowerCase() == 'senha' && visiblePassword
                          ? TextInputType.visiblePassword
                          : TextInputType.text,
                  obscureText:
                      widget.label.toLowerCase() == 'senha' && !visiblePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: widget.label,
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 18,
                      color: AppColors.grey,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              widget.label.toLowerCase() == 'senha'
                  ? Material(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withOpacity(0.8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            visiblePassword = !visiblePassword;
                          });
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            visiblePassword
                                ? FeatherIcons.eyeOff
                                : FeatherIcons.eye,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : widget.suffixIcon != null
                      ? widget.suffixIcon!
                      : Container(),
            ],
          ),
        ),
        widget.error != null
            ? Text(
                widget.error!,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.white,
                ),
              )
            : const SizedBox(
                height: 10,
              )
      ],
    );
  }
}
