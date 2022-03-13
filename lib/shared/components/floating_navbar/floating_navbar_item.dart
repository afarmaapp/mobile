import 'package:flutter/material.dart';

class FloatingNavbarItem {
  int? count = 0;
  final String? title;
  final IconData? icon;
  final Image? image;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Widget? customWidget;

  FloatingNavbarItem({
    this.title,
    this.icon,
    this.image,
    this.selectedColor,
    this.unselectedColor,
    this.customWidget = const SizedBox(),
  });
}
