import 'package:app/helper/app_colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarWidget {
  SnackBar alert(Map resp) {
    return SnackBar(
      backgroundColor: resp["error"] ? AppColors.primary : Colors.green[400],
      content: Row(
        children: [
          Icon(
            resp["error"] ? Icons.warning_amber_rounded : Icons.done,
            size: 32,
            color: AppColors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: AutoSizeText(
              resp["msg"],
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
