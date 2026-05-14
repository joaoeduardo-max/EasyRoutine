import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CabecalhoMarca extends StatelessWidget {
  const CabecalhoMarca({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.primaria,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text('📋', style: TextStyle(fontSize: 54)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rotina',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textoForte,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
