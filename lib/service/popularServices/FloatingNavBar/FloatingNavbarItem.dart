import 'package:flutter/material.dart';

class FloatingNavbarItem {
  int count = 0;
  final String title;
  final IconData icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Widget customWidget;

  FloatingNavbarItem({
    required this.icon,
    required this.title,
    this.selectedColor,
    this.unselectedColor,
    this.customWidget = const SizedBox(),
  });
}
