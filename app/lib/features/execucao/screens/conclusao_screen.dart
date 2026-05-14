import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/botao_grande.dart';

class ConclusaoScreen extends StatelessWidget {
  final String tituloRotina;
  final int quantidadeTarefas;
  final int? duracaoTotalMinutos;

  const ConclusaoScreen({
    super.key,
    required this.tituloRotina,
    required this.quantidadeTarefas,
    this.duracaoTotalMinutos,
  });

  String _textoTarefas() {
    return quantidadeTarefas == 1
        ? '1 tarefa concluída'
        : '$quantidadeTarefas tarefas concluídas';
  }

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sucesso,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltarParaHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.sucesso,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text('🎉', style: TextStyle(fontSize: 120)),
                const SizedBox(height: 24),
                Text(
                  'Você concluiu sua rotina!',
                  style: AppTextStyles.displayConclusao
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  tituloRotina,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                _CartaoEstatisticas(
                  quantidadeTarefas: quantidadeTarefas,
                  textoQuantidade: _textoTarefas(),
                  duracaoTotalMinutos: duracaoTotalMinutos,
                ),
                const Spacer(),
                Theme(

                  data: Theme.of(context).copyWith(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.sucesso,
                        minimumSize: const Size.fromHeight(72),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  child: BotaoGrande(
                    texto: 'Voltar',
                    aoTocar: () => _voltarParaHome(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _voltarParaHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _CartaoEstatisticas extends StatelessWidget {
  final int quantidadeTarefas;
  final String textoQuantidade;
  final int? duracaoTotalMinutos;

  const _CartaoEstatisticas({
    required this.quantidadeTarefas,
    required this.textoQuantidade,
    required this.duracaoTotalMinutos,
  });

  @override
  Widget build(BuildContext context) {
    final temDuracao = duracaoTotalMinutos != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Estatistica(
            icone: Icons.checklist_rounded,
            texto: textoQuantidade,
          ),
          if (temDuracao) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 14),
              color: Colors.white.withValues(alpha: 0.35),
            ),
            _Estatistica(
              icone: Icons.schedule_rounded,
              texto: '~$duracaoTotalMinutos minutos',
            ),
          ],
        ],
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _Estatistica({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
