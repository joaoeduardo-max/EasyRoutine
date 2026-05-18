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
  final String? corRotinaHex;

  const FormTarefaScreen({
    super.key,
    required this.rotinaId,
    this.tarefa,
    this.corRotinaHex,
  });

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
  TimeOfDay? _horarioSelecionado;
  Color? _corSelecionada;
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
      _horarioSelecionado = _parseHorario(t.horario);
      _corSelecionada = _parseCor(t.cor);
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

  TimeOfDay? _parseHorario(String? texto) {
    if (texto == null || texto.isEmpty) return null;
    final partes = texto.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatarHorario(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color? _parseCor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final puro = hex.replaceFirst('#', '');
    try {
      return Color(int.parse('FF$puro', radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _corParaHex(Color c) {
    final argb = c.toARGB32();
    final rgb = argb & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> _escolherHorario() async {
    final escolhido = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (escolhido != null) {
      setState(() => _horarioSelecionado = escolhido);
    }
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
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
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
      final horarioStr = _horarioSelecionado != null
          ? _formatarHorario(_horarioSelecionado!)
          : null;
      final corStr =
          _corSelecionada != null ? _corParaHex(_corSelecionada!) : null;

      final t = widget.tarefa;
      if (t == null) {
        await _service.adicionarTarefa(
          widget.rotinaId,
          titulo: titulo,
          icone: _iconeSelecionado,
          duracaoMinutos: duracao,
          horario: horarioStr,
          cor: corStr,
        );
      } else {
        await _service.atualizarTarefa(
          t.id,
          titulo: titulo,
          icone: _iconeSelecionado,
          duracaoMinutos: duracao,
          duracaoExplicitamenteNula: duracao == null,
          horario: horarioStr,
          horarioExplicitamenteNulo: horarioStr == null,
          cor: corStr,
          corExplicitamenteNula: corStr == null,
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
    final corRotina = _parseCor(widget.corRotinaHex);
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
                const SizedBox(height: 16),
                _CampoHorario(
                  horario: _horarioSelecionado,
                  aoTocar: _escolherHorario,
                  aoLimpar: _horarioSelecionado == null
                      ? null
                      : () => setState(() => _horarioSelecionado = null),
                ),
                const SizedBox(height: 28),
                Text('Cor', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _corSelecionada == null
                      ? 'Usando a cor da rotina'
                      : 'Cor personalizada',
                  style: const TextStyle(fontSize: 14, color: AppColors.textoFraco),
                ),
                const SizedBox(height: 12),
                _SeletorCorTarefa(
                  cores: AppColors.paletaRotinas,
                  selecionada: _corSelecionada,
                  corRotina: corRotina,
                  aoSelecionar: (c) => setState(() => _corSelecionada = c),
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

class _CampoHorario extends StatelessWidget {
  final TimeOfDay? horario;
  final VoidCallback aoTocar;
  final VoidCallback? aoLimpar;

  const _CampoHorario({
    required this.horario,
    required this.aoTocar,
    required this.aoLimpar,
  });

  String _formatar(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final texto = horario != null ? _formatar(horario!) : 'Sem horário';
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.tinta, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                color: AppColors.textoFraco, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Horário (opcional)',
                    style: TextStyle(fontSize: 13, color: AppColors.textoFraco),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: horario != null
                          ? AppColors.textoForte
                          : AppColors.textoFraco,
                    ),
                  ),
                ],
              ),
            ),
            if (aoLimpar != null)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textoFraco),
                tooltip: 'Limpar horário',
                onPressed: aoLimpar,
              ),
          ],
        ),
      ),
    );
  }
}

class _SeletorCorTarefa extends StatelessWidget {
  final List<Color> cores;
  final Color? selecionada;
  final Color? corRotina;
  final ValueChanged<Color?> aoSelecionar;

  const _SeletorCorTarefa({
    required this.cores,
    required this.selecionada,
    required this.corRotina,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    final padraoEscolhida = selecionada == null;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        GestureDetector(
          onTap: () => aoSelecionar(null),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: corRotina ?? AppColors.fundo,
              shape: BoxShape.circle,
              border: Border.all(
                color: padraoEscolhida ? AppColors.tinta : AppColors.nevoa,
                width: padraoEscolhida ? 3 : 1.5,
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: corRotina != null ? Colors.white : AppColors.textoFraco,
              size: 22,
            ),
          ),
        ),
        ...cores.map((c) {
          final escolhida = c == selecionada;
          return GestureDetector(
            onTap: () => aoSelecionar(c),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: escolhida ? AppColors.textoForte : Colors.transparent,
                  width: 4,
                ),
              ),
              child: escolhida
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : null,
            ),
          );
        }),
      ],
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
                color: escolhido ? AppColors.tinta : AppColors.nevoa,
                width: escolhido ? 2.5 : 1.5,
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
