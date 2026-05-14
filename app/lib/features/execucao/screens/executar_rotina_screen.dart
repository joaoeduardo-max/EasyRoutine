import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rotinas/models/rotina.dart';
import '../../rotinas/models/tarefa.dart';
import 'conclusao_screen.dart';

class ExecutarRotinaScreen extends StatefulWidget {
  final Rotina rotina;
  final List<Tarefa> tarefas;

  const ExecutarRotinaScreen({
    super.key,
    required this.rotina,
    required this.tarefas,
  });

  @override
  State<ExecutarRotinaScreen> createState() => _ExecutarRotinaScreenState();
}

class _ExecutarRotinaScreenState extends State<ExecutarRotinaScreen> {
  int _indice = 0;

  Tarefa get _tarefaAtual => widget.tarefas[_indice];
  Tarefa? get _proximaTarefa =>
      _indice + 1 < widget.tarefas.length ? widget.tarefas[_indice + 1] : null;
  int get _total => widget.tarefas.length;

  int? _duracaoTotalMinutos() {
    final soma = widget.tarefas
        .map((t) => t.duracaoMinutos ?? 0)
        .fold<int>(0, (a, b) => a + b);
    return soma == 0 ? null : soma;
  }

  void _pronto() {
    if (_indice + 1 >= _total) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConclusaoScreen(
            tituloRotina: widget.rotina.titulo,
            quantidadeTarefas: _total,
            duracaoTotalMinutos: _duracaoTotalMinutos(),
          ),
        ),
      );
      return;
    }
    setState(() => _indice++);
  }

  void _anterior() {
    if (_indice == 0) return;
    setState(() => _indice--);
  }

  Future<bool> _confirmarSair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da rotina?'),
        content: const Text('Seu progresso atual não será salvo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    return confirmou == true;
  }

  @override
  Widget build(BuildContext context) {
    final cor = widget.rotina.corFlutter;
    final t = _tarefaAtual;
    final progresso = '${_indice + 1} de $_total';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: cor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmarSair() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: cor,
        body: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                child: Row(
                  children: [
                    Text(
                      progresso,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),

                    if (_indice > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 28),
                        tooltip: 'Tarefa anterior',
                        onPressed: _anterior,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      tooltip: 'Sair',
                      onPressed: () async {
                        if (await _confirmarSair() && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_indice + 1) / _total,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.icone, style: const TextStyle(fontSize: 160)),
                      const SizedBox(height: 32),
                      Text(
                        t.titulo,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayTarefa
                            .copyWith(color: Colors.white),
                      ),
                      if (t.duracaoMinutos != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          '${t.duracaoMinutos} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 88,
                  child: ElevatedButton(
                    onPressed: _pronto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Pronto!', style: AppTextStyles.botaoExecutar),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 32,
                  child: _proximaTarefa == null
                      ? Center(
                          child: Text(
                            'Última tarefa!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Depois: ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _proximaTarefa!.icone,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _proximaTarefa!.titulo,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
