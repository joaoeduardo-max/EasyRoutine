import 'package:flutter/material.dart';
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
    return Material(
      color: rotina.corFlutter,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
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
                      style: AppTextStyles.tituloCard
                          .copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (descricao != null && descricao.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        descricao,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
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
                        _SeloContador(texto: _textoContador()),
                        if (periodo != null)
                          _SeloPeriodo(periodo: periodo),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeloContador extends StatelessWidget {
  final String texto;
  const _SeloContador({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.checklist_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            texto,
            style: AppTextStyles.selo
                .copyWith(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SeloPeriodo extends StatelessWidget {
  final Periodo periodo;
  const _SeloPeriodo({required this.periodo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(periodo.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            periodo.rotulo,
            style: AppTextStyles.selo
                .copyWith(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
