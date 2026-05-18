import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BotaoGrande extends StatelessWidget {
  final String texto;
  final VoidCallback? aoTocar;
  final bool carregando;

  const BotaoGrande({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: carregando ? null : aoTocar,
      child: carregando
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.papel),
              ),
            )
          : Text(texto),
    );
  }
}
