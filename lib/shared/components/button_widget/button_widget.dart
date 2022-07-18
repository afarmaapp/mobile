import 'package:app/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    Key? key,
    required this.label,
    required this.onTap,
    this.expanded,
    this.color,
    this.marginBottom,
    this.loading,
  }) : super(key: key);

  final String label;
  final VoidCallback onTap;
  final double? marginBottom;
  final bool? loading;
  final bool? expanded;
  final Color? color;

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Material(
          color: widget.color ?? AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: Container(
              width: widget.expanded != null && widget.expanded!
                  ? deviceWidth * 0.9
                  : deviceWidth * 0.6,
              height: deviceWidth * 0.125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: widget.loading != null && widget.loading!
                  ? SizedBox(
                      width: deviceWidth * 0.075,
                      height: deviceWidth * 0.075,
                      child: const CircularProgressIndicator(),
                    )
                  : Text(
                      widget.label,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
        widget.marginBottom != null
            ? SizedBox(
                height: widget.marginBottom!,
              )
            : Container(),
      ],
    );
  }
}
