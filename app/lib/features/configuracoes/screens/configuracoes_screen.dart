import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../configuracoes_provider.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: LimiteLeitura(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: const [
              _SecaoTitulo(texto: 'Acessibilidade'),
              SizedBox(height: 12),
              _TileEscalaFonte(),
              SizedBox(height: 12),
              _TileVibracao(),
              SizedBox(height: 32),
              _SecaoTitulo(texto: 'Sobre'),
              SizedBox(height: 12),
              _CartaoSobre(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: AppColors.textoFraco,
      ),
    );
  }
}

class _TileVibracao extends StatelessWidget {
  const _TileVibracao();

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfiguracoesProvider>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nevoa, width: 1.5),
      ),
      child: SwitchListTile(
        value: config.vibracaoLigada,
        onChanged: (v) => config.definirVibracao(v),
        activeThumbColor: AppColors.coral,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.vibration_rounded,
              color: AppColors.coral, size: 24),
        ),
        title: const Text(
          'Vibração',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textoForte,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            'Confirmações táteis ao tocar em botões',
            style: TextStyle(fontSize: 14, color: AppColors.textoFraco),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _TileEscalaFonte extends StatelessWidget {
  const _TileEscalaFonte();

  String _rotulo(double v) {
    if (v == 1.0) return 'Padrão';
    if (v == 1.2) return 'Maior';
    return 'Muito maior';
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfiguracoesProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nevoa, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_size_rounded,
                    color: AppColors.coral, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tamanho do texto',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoForte,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _rotulo(config.escalaFonte),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textoFraco,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ConfiguracoesProvider.escalasDisponiveis.map((escala) {
              final escolhida = config.escalaFonte == escala;
              return InkWell(
                onTap: () => config.definirEscalaFonte(escala),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: escolhida ? AppColors.tinta : AppColors.superficie,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: escolhida ? AppColors.tinta : AppColors.nevoa,
                      width: escolhida ? 2.5 : 1.5,
                    ),
                  ),
                  child: Text(
                    _rotulo(escala),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: escolhida ? AppColors.papel : AppColors.textoForte,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CartaoSobre extends StatelessWidget {
  const _CartaoSobre();

  static const _versao = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nevoa, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/logos/symbol-color.svg',
            width: 56,
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Easy',
                  style: AppTheme.frauncesRegular(
                    fontSize: 22,
                    color: AppColors.tinta,
                  ),
                ),
                TextSpan(
                  text: 'Routine',
                  style: AppTheme.frauncesItalic(
                    fontSize: 22,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Versão $_versao',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textoFraco,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rotinas visuais para um dia mais previsível.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textoForte,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          const _PaletaMarca(),
        ],
      ),
    );
  }
}

class _PaletaMarca extends StatelessWidget {
  const _PaletaMarca();

  @override
  Widget build(BuildContext context) {
    const cores = <(Color, String)>[
      (AppColors.coral, 'Coral'),
      (AppColors.salvia, 'Sálvia'),
      (AppColors.oceano, 'Oceano'),
      (AppColors.sol, 'Sol'),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: cores.map((c) {
        final (cor, nome) = c;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nome,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textoFraco,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
