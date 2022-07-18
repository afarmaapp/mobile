import 'package:app/helper/app_colors.dart';
import 'package:app/modules/login/controllers/login_controller.dart/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    required this.label,
    required this.onTap,
    this.value,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  final String label;
  final String? error;
  final DateTime? value;
  final VoidCallback onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? birthdayDate;
  final loginController = GetIt.I.get<LoginController>();
  bool visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: widget.onTap,
      child: Observer(builder: (context) {
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
                    child: Text(
                      widget.value != null
                          ? '${widget.value!.day > 9 ? widget.value!.day : '0${widget.value!.day}'}/${widget.value!.month > 9 ? widget.value!.month : '0${widget.value!.month}'}/${widget.value!.year}'
                          : widget.label,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: AppColors.grey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  widget.suffixIcon != null ? widget.suffixIcon! : Container(),
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
      }),
    );
  }
}
