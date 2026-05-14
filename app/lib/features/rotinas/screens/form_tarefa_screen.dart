import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/botao_grande.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../models/tarefa.dart';
import '../rotinas_service.dart';

class FormTarefaScreen extends StatefulWidget {
  final String rotinaId;
  final Tarefa? tarefa;

  const FormTarefaScreen({super.key, required this.rotinaId, this.tarefa});

  @override
  State<FormTarefaScreen> createState() => _FormTarefaScreenState();
}

class _FormTarefaScreenState extends State<FormTarefaScreen> {
  static const _icones = [
    '☀️', '🌙', '🛏️', '🍴',
    '🛁', '🦷', '📚', '🚌',
    '🏠', '✏️', '🎮', '🚿',
    '💧', '🎵', '🐶', '🧸',
  ];

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _service = RotinasService();

  late String _iconeSelecionado;
  bool _enviando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    if (t != null) {
      _tituloController.text = t.titulo;
      _duracaoController.text = t.duracaoMinutos?.toString() ?? '';
      _iconeSelecionado = _icones.contains(t.icone) ? t.icone : _icones.first;
    } else {
      _iconeSelecionado = _icones.first;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  Future<void> _excluir() async {
    final t = widget.tarefa;
    if (t == null) return;
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
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    setState(() => _enviando = true);
    try {
      await _service.excluirTarefa(t.id);
      if (!mounted) return;
      mostrarSnack(context, 'Tarefa removida');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      mostrarSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final titulo = _tituloController.text.trim();
      final duracaoTexto = _duracaoController.text.trim();
      final duracao = duracaoTexto.isEmpty ? null : int.parse(duracaoTexto);

      final t = widget.tarefa;
      if (t == null) {
        await _service.adicionarTarefa(
          widget.rotinaId,
          titulo: titulo,
          icone: _iconeSelecionado,
          duracaoMinutos: duracao,
        );
      } else {

        await _service.atualizarTarefa(
          t.id,
          titulo: titulo,
          icone: _iconeSelecionado,
          duracaoMinutos: duracao,
          duracaoExplicitamenteNula: duracao == null,
        );
      }
      if (!mounted) return;
      mostrarSnack(context, t == null ? 'Tarefa adicionada' : 'Tarefa atualizada');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      mostrarSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa')),
      body: SafeArea(
        child: LimiteLeitura(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
              children: [
                TextFormField(
                  controller: _tituloController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe um título';
                    }
                    if (v.trim().length > 80) return 'Título muito longo';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _duracaoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Duração em minutos (opcional)',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return 'Use um número maior que zero';
                    }
                    if (n > 1440) return 'Duração não pode passar de 24h';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Text('Ícone', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _SeletorIcone(
                  icones: _icones,
                  selecionado: _iconeSelecionado,
                  aoSelecionar: (i) => setState(() => _iconeSelecionado = i),
                ),
                const SizedBox(height: 32),
                BotaoGrande(
                  texto: _editando ? 'Salvar alterações' : 'Adicionar tarefa',
                  carregando: _enviando,
                  aoTocar: _salvar,
                ),
                if (_editando) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _enviando ? null : _excluir,
                    icon: const Icon(Icons.delete_outline, color: AppColors.erro),
                    label: const Text(
                      'Excluir tarefa',
                      style: TextStyle(color: AppColors.erro, fontSize: 16),
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeletorIcone extends StatelessWidget {
  final List<String> icones;
  final String selecionado;
  final ValueChanged<String> aoSelecionar;

  const _SeletorIcone({
    required this.icones,
    required this.selecionado,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: icones.map((emoji) {
        final escolhido = emoji == selecionado;
        return GestureDetector(
          onTap: () => aoSelecionar(emoji),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.superficie,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: escolhido ? AppColors.primaria : const Color(0xFFCCCCCC),
                width: escolhido ? 3 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
        );
      }).toList(),
    );
  }
}
