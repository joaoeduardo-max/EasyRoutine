import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/botao_grande.dart';
import '../../../shared/widgets/feedback.dart';
import '../../execucao/screens/executar_rotina_screen.dart';
import '../models/rotina.dart';
import '../models/tarefa.dart';
import '../rotinas_provider.dart';
import '../rotinas_service.dart';
import 'form_rotina_screen.dart';
import 'form_tarefa_screen.dart';

class DetalhesRotinaScreen extends StatefulWidget {
  final String rotinaId;

  const DetalhesRotinaScreen({super.key, required this.rotinaId});

  @override
  State<DetalhesRotinaScreen> createState() => _DetalhesRotinaScreenState();
}

class _DetalhesRotinaScreenState extends State<DetalhesRotinaScreen> {
  final _service = RotinasService();

  Rotina? _rotina;
  List<Tarefa> _tarefas = [];
  bool _carregando = true;
  bool _salvandoOrdem = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final r = await _service.buscarDetalhes(widget.rotinaId);
      if (!mounted) return;
      setState(() {
        _rotina = r;
        _tarefas = r.tarefas ?? [];
        _carregando = false;
      });

      context.read<RotinasProvider>().atualizarRotinaLocal(r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      _erro(e);
    }
  }

  void _erro(Object e) {
    mostrarSnack(context, e.toString());
  }

  Future<void> _abrirForm({Tarefa? tarefa}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormTarefaScreen(
          rotinaId: widget.rotinaId,
          tarefa: tarefa,
          corRotinaHex: _rotina?.cor,
        ),
      ),
    );
    if (resultado == true) {
      _carregar();
    }
  }

  Future<void> _editarRotina() async {
    final r = _rotina;
    if (r == null) return;
    final mudou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FormRotinaScreen(rotina: r)),
    );
    if (mudou == true) _carregar();
  }

  void _executar() {
    final r = _rotina;
    if (r == null || _tarefas.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExecutarRotinaScreen(rotina: r, tarefas: _tarefas),
      ),
    );
  }

  Future<void> _excluirTarefa(Tarefa t) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('"${t.titulo}" será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await _service.excluirTarefa(t.id);
      if (!mounted) return;
      mostrarSnack(context, 'Tarefa removida');
      _carregar();
    } catch (e) {
      _erro(e);
    }
  }

  Future<void> _excluirRotina() async {
    final r = _rotina;
    if (r == null) return;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir rotina?'),
        content: Text(
          '"${r.titulo}" e todas as suas tarefas serão removidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await context.read<RotinasProvider>().excluir(r.id);
      if (!mounted) return;
      mostrarSnack(context, 'Rotina excluída');
      Navigator.of(context).pop();
    } catch (e) {
      _erro(e);
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    setState(() {
      final movida = _tarefas.removeAt(oldIndex);
      _tarefas.insert(newIndex, movida);
      _salvandoOrdem = true;
    });

    try {
      final ordemIds = _tarefas.map((t) => t.id).toList();
      final atualizadas =
          await _service.reordenarTarefas(widget.rotinaId, ordemIds);
      if (!mounted) return;
      setState(() {
        _tarefas = atualizadas;
        _salvandoOrdem = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvandoOrdem = false);
      _erro(e);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rotina = _rotina;

    if (_carregando && rotina == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (rotina == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Rotina não encontrada')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: rotina.corFlutter,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
      backgroundColor: rotina.corFlutter,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              rotina: rotina,
              tarefas: _tarefas,
              aoVoltar: () => Navigator.of(context).maybePop(),
              aoEditar: _editarRotina,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.fundo,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: RefreshIndicator(
                    onRefresh: _carregar,
                    child: _construirConteudoLista(rotina),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.fundo,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BotaoGrande(
                texto: 'Executar rotina',
                aoTocar: _tarefas.isEmpty ? null : _executar,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _excluirRotina,
                  icon: const Icon(Icons.delete_outline, color: AppColors.erro),
                  label: const Text(
                    'Excluir rotina',
                    style: TextStyle(
                      color: AppColors.erro,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.erro, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(),
        backgroundColor: rotina.corFlutter,
        foregroundColor: AppColors.corDeContrasteSobre(rotina.corFlutter),
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Nova tarefa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  Widget _construirConteudoLista(Rotina rotina) {
    if (_tarefas.isEmpty) {
      return _EstadoVazioTarefas(corAcento: rotina.corFlutter);
    }
    return Stack(
      children: [
        ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: _tarefas.length,
          onReorder: _onReorder,
          buildDefaultDragHandles: false,
          itemBuilder: (_, i) {
            final t = _tarefas[i];
            return _TarefaTile(
              key: ValueKey(t.id),
              indice: i,
              tarefa: t,
              corRotina: rotina.corFlutter,
              aoTocar: () => _abrirForm(tarefa: t),
              aoExcluir: () => _excluirTarefa(t),
            );
          },
        ),
        if (_salvandoOrdem)
          const Positioned(
            top: 8,
            right: 16,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final Rotina rotina;
  final List<Tarefa> tarefas;
  final VoidCallback aoVoltar;
  final VoidCallback aoEditar;

  const _Header({
    required this.rotina,
    required this.tarefas,
    required this.aoVoltar,
    required this.aoEditar,
  });

  String _textoTarefas() {
    switch (tarefas.length) {
      case 0:
        return 'Sem tarefas';
      case 1:
        return '1 tarefa';
      default:
        return '${tarefas.length} tarefas';
    }
  }

  int? _duracaoTotal() {
    final soma = tarefas
        .map((t) => t.duracaoMinutos ?? 0)
        .fold<int>(0, (a, b) => a + b);
    return soma == 0 ? null : soma;
  }

  @override
  Widget build(BuildContext context) {
    final descricao = rotina.descricao;
    final duracao = _duracaoTotal();
    final cor = rotina.corFlutter;
    final corTexto = AppColors.corDeContrasteSobre(cor);
    final corSelo = AppColors.seloSobre(cor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: corTexto, size: 28),
                tooltip: 'Voltar',
                onPressed: aoVoltar,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: corTexto, size: 26),
                tooltip: 'Editar rotina',
                onPressed: aoEditar,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'rotina_icone_${rotina.id}',
                  child: Text(rotina.icone, style: const TextStyle(fontSize: 72)),
                ),
                const SizedBox(height: 8),
                Text(
                  rotina.titulo,
                  style: AppTextStyles.headerHero.copyWith(color: corTexto),
                ),
                if (descricao != null && descricao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    descricao,
                    style: TextStyle(
                      color: corTexto.withValues(alpha: 0.9),
                      fontSize: 17,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _Selo(
                      icone: Icons.checklist_rounded,
                      texto: _textoTarefas(),
                      corBg: corSelo,
                      corFg: corTexto,
                    ),
                    if (duracao != null)
                      _Selo(
                        icone: Icons.schedule_rounded,
                        texto: '~$duracao min',
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
    );
  }
}

class _Selo extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color corBg;
  final Color corFg;
  const _Selo({
    required this.icone,
    required this.texto,
    required this.corBg,
    required this.corFg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: corBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: corFg, size: 18),
          const SizedBox(width: 6),
          Text(
            texto,
            style: AppTextStyles.selo.copyWith(color: corFg),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazioTarefas extends StatelessWidget {
  final Color corAcento;
  const _EstadoVazioTarefas({required this.corAcento});

  @override
  Widget build(BuildContext context) {

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
      children: [
        Center(
          child: Opacity(
            opacity: 0.8,
            child: SvgPicture.asset(
              'assets/logos/symbol-color.svg',
              width: 96,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Nenhuma tarefa ainda',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Toque em "Nova tarefa" para começar a montar sua rotina.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TarefaTile extends StatelessWidget {
  final int indice;
  final Tarefa tarefa;
  final Color corRotina;
  final VoidCallback aoTocar;
  final VoidCallback aoExcluir;

  const _TarefaTile({
    super.key,
    required this.indice,
    required this.tarefa,
    required this.corRotina,
    required this.aoTocar,
    required this.aoExcluir,
  });

  Color _corTarefa() {
    final hex = tarefa.cor;
    if (hex == null || hex.isEmpty) return corRotina;
    final puro = hex.replaceFirst('#', '');
    try {
      return Color(int.parse('FF$puro', radix: 16));
    } catch (_) {
      return corRotina;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corAcento = _corTarefa();
    final horario = tarefa.horario;
    final duracao = tarefa.duracaoMinutos;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.superficie,
        elevation: 1,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 48,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: corAcento,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(tarefa.icone, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarefa.titulo,
                        style: AppTextStyles.tituloTarefa
                            .copyWith(color: AppColors.textoForte),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (horario != null || duracao != null) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (horario != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: corAcento,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    horario,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: corAcento,
                                    ),
                                  ),
                                ],
                              ),
                            if (duracao != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: AppColors.textoFraco,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$duracao min',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textoFraco,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.erro,
                    size: 26,
                  ),
                  tooltip: 'Excluir tarefa',
                  onPressed: aoExcluir,
                ),
                ReorderableDragStartListener(
                  index: indice,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.drag_indicator,
                      color: AppColors.textoFraco,
                      size: 28,
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
