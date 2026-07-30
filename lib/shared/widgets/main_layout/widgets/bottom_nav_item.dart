import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isCart;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isCart = false,
  });
}
