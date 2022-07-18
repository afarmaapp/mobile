import 'package:app/helper/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

enum SocialButtonType { google, apple, none }

class SocialButtonWidget extends StatefulWidget {
  const SocialButtonWidget({
    Key? key,
    required this.type,
    required this.label,
    required this.onTap,
    this.loading,
  }) : super(key: key);

  final SocialButtonType type;
  final String label;
  final VoidCallback onTap;
  final bool? loading;

  @override
  _SocialButtonWidgetState createState() => _SocialButtonWidgetState();
}

class _SocialButtonWidgetState extends State<SocialButtonWidget> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: Container(
              width: deviceWidth * 0.8,
              height: deviceWidth * 0.125,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              child: widget.loading != null && widget.loading!
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.type != SocialButtonType.none
                            ? Image.asset(
                                widget.type == SocialButtonType.google
                                    ? 'assets/images/google-icon.png'
                                    : widget.type == SocialButtonType.apple
                                        ? ''
                                        : '',
                                width: 30,
                              )
                            : Container(),
                        Expanded(child: Container()),
                        Text(
                          widget.label,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
