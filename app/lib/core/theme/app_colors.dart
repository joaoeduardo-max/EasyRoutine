import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color tinta = Color(0xFF0E1A24);
  static const Color papel = Color(0xFFF5F1EA);
  static const Color coral = Color(0xFFFF6B5B);
  static const Color salvia = Color(0xFF7BA88C);
  static const Color oceano = Color(0xFF2E5C8A);
  static const Color sol = Color(0xFFF4C95D);
  static const Color nevoa = Color(0xFFE8E2D6);

  static const Color primaria = tinta;
  static const Color primariaEscura = oceano;
  static const Color destaque = coral;

  static const Color fundo = papel;
  static const Color superficie = Colors.white;

  static const Color textoForte = tinta;
  static const Color textoFraco = Color(0xFF34404A);

  static const Color sucesso = salvia;
  static const Color erro = Color(0xFFC62828);

  static const List<Color> paletaRotinas = [
    coral,
    salvia,
    oceano,
    sol,
    Color(0xFF7B1FA2),
    Color(0xFFEF6C00),
    Color(0xFFC2185B),
    Color(0xFF00838F),
  ];

  static Color corDeContrasteSobre(Color fundo) {
    return fundo.computeLuminance() > 0.55 ? tinta : papel;
  }

  static Color seloSobre(Color fundo) {
    final escuro = fundo.computeLuminance() <= 0.55;
    return escuro
        ? papel.withValues(alpha: 0.18)
        : tinta.withValues(alpha: 0.12);
  }
}
