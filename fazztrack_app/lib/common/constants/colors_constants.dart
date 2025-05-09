import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primaryDarkBlue = Color(0xFF0A2647);
  static const Color primaryTurquoise = Color(0xFF00E5E8);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Colores complementarios
  static const Color secondaryBlue = Color(0xFF144272);
  static const Color lightBlue = Color(0xFF205295);
  static const Color lightGray = Color(0xFFF2F2F2);
  static const Color darkGray = Color(0xFF333333);

  // Colores de acento/estado
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF4D03F);

  // Colores de fondo
  static const Color background = primaryDarkBlue;
  static const Color backgroundSecondary = secondaryBlue;
  static const Color card = secondaryBlue;
  static const Color alternativeBackground = lightGray;

  // Colores de elementos interactivos
  static const Color primary = primaryTurquoise;
  static const Color secondary = lightBlue;

  // Colores de texto
  static const Color textPrimary = primaryWhite;
  static const Color textSecondary = darkGray;
  static const Color textLight = primaryWhite;

  static const List<Color> gradient = [primaryDarkBlue, secondaryBlue];

  static const Color shadow = Color(0x40000000);
}
