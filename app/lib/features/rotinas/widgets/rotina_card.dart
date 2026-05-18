import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/rotina.dart';

class RotinaCard extends StatelessWidget {
  final Rotina rotina;
  final VoidCallback? aoTocar;
  final VoidCallback? aoSegurar;

  const RotinaCard({
    super.key,
    required this.rotina,
    this.aoTocar,
    this.aoSegurar,
  });

  String _textoContador() {
    switch (rotina.totalTarefas) {
      case 0:
        return 'Sem tarefas ainda';
      case 1:
        return '1 tarefa';
      default:
        return '${rotina.totalTarefas} tarefas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final descricao = rotina.descricao;
    final periodo = rotina.periodo;
    final cor = rotina.corFlutter;
    final corTexto = AppColors.corDeContrasteSobre(cor);
    final corSelo = AppColors.seloSobre(cor);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.tinta.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: cor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: aoTocar,
          onLongPress: aoSegurar,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'rotina_icone_${rotina.id}',

                  flightShuttleBuilder: (_, animation, _, _, _) {
                    return DefaultTextStyle(
                      style: const TextStyle(fontSize: 52),
                      child: Material(
                        color: Colors.transparent,
                        child: Text(rotina.icone,
                            style: const TextStyle(fontSize: 52)),
                      ),
                    );
                  },
                  child: Text(rotina.icone, style: const TextStyle(fontSize: 52)),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rotina.titulo,
                        style: AppTextStyles.tituloCard.copyWith(color: corTexto),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (descricao != null && descricao.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          descricao,
                          style: TextStyle(
                            color: corTexto.withValues(alpha: 0.88),
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Selo(
                            texto: _textoContador(),
                            icone: Icons.checklist_rounded,
                            corBg: corSelo,
                            corFg: corTexto,
                          ),
                          if (periodo != null)
                            _Selo(
                              texto: periodo.rotulo,
                              emoji: periodo.emoji,
                              corBg: corSelo,
                              corFg: corTexto,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final String? emoji;
  final Color corBg;
  final Color corFg;

  const _Selo({
    required this.texto,
    required this.corBg,
    required this.corFg,
    this.icone,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: corBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null)
            Icon(icone, color: corFg, size: 16),
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: AppTextStyles.selo.copyWith(color: corFg, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
