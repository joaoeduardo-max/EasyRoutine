import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CabecalhoMarca extends StatelessWidget {
  const CabecalhoMarca({
    super.key,
    this.simboloTamanho = 72,
    this.fonteTamanho = 36,
    this.mostrarWordmark = true,
  });

  final double simboloTamanho;
  final double fonteTamanho;
  final bool mostrarWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/logos/symbol-color.svg',
          width: simboloTamanho,
          height: simboloTamanho,
        ),
        if (mostrarWordmark) ...[
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Easy',
                  style: AppTheme.frauncesRegular(
                    fontSize: fonteTamanho,
                    color: AppColors.tinta,
                  ),
                ),
                TextSpan(
                  text: 'Routine',
                  style: AppTheme.frauncesItalic(
                    fontSize: fonteTamanho,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
