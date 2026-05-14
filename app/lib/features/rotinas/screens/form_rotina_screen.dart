import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/botao_grande.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../models/rotina.dart';
import '../rotinas_provider.dart';

class FormRotinaScreen extends StatefulWidget {
  final Rotina? rotina;

  const FormRotinaScreen({super.key, this.rotina});

  @override
  State<FormRotinaScreen> createState() => _FormRotinaScreenState();
}

class _FormRotinaScreenState extends State<FormRotinaScreen> {
  static const _icones = [
    '☀️', '🌙', '🛏️', '🍴',
    '🛁', '🦷', '📚', '🚌',
    '🏠', '✏️', '🎮', '🚿',
  ];

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  Color _corSelecionada = AppColors.paletaRotinas.first;
  String _iconeSelecionado = _icones.first;
  bool _enviando = false;

  bool get _editando => widget.rotina != null;

  @override
  void initState() {
    super.initState();
    final r = widget.rotina;
    if (r != null) {
      _tituloController.text = r.titulo;
      _descricaoController.text = r.descricao ?? '';
      _corSelecionada = AppColors.paletaRotinas.firstWhere(
        (c) => _corParaHex(c) == r.cor.toUpperCase(),
        orElse: () => AppColors.paletaRotinas.first,
      );
      _iconeSelecionado = _icones.contains(r.icone) ? r.icone : _icones.first;
    }

    _tituloController.addListener(_onChange);
    _descricaoController.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _tituloController.removeListener(_onChange);
    _descricaoController.removeListener(_onChange);
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _corParaHex(Color c) {
    final argb = c.toARGB32();
    final rgb = argb & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final provider = context.read<RotinasProvider>();
      final titulo = _tituloController.text.trim();
      final descricaoBruta = _descricaoController.text.trim();
      final descricao = descricaoBruta.isEmpty ? null : descricaoBruta;
      final cor = _corParaHex(_corSelecionada);

      final r = widget.rotina;
      if (r == null) {
        await provider.criar(
          titulo: titulo,
          descricao: descricao,
          cor: cor,
          icone: _iconeSelecionado,
        );
      } else {
        await provider.atualizar(
          r.id,
          titulo: titulo,
          descricao: descricao,
          cor: cor,
          icone: _iconeSelecionado,
        );
      }
      if (!mounted) return;
      mostrarSnack(
        context,
        _editando ? 'Rotina atualizada' : 'Rotina criada',
      );
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
      appBar: AppBar(
        title: Text(_editando ? 'Editar rotina' : 'Nova rotina'),
      ),
      body: SafeArea(
        child: LimiteLeitura(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
              children: [
                _PreviewRotina(
                  titulo: _tituloController.text.trim(),
                  descricao: _descricaoController.text.trim(),
                  cor: _corSelecionada,
                  icone: _iconeSelecionado,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _tituloController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe um título';
                    }
                    if (v.trim().length > 80) {
                      return 'Título muito longo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                  ),
                  validator: (v) {
                    if (v != null && v.length > 500) {
                      return 'Descrição muito longa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Text('Cor', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _SeletorCor(
                  cores: AppColors.paletaRotinas,
                  selecionada: _corSelecionada,
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
                  texto: _editando ? 'Salvar alterações' : 'Criar rotina',
                  carregando: _enviando,
                  aoTocar: _salvar,
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewRotina extends StatelessWidget {
  final String titulo;
  final String descricao;
  final Color cor;
  final String icone;

  const _PreviewRotina({
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final tituloExibido = titulo.isEmpty ? 'Sua nova rotina' : titulo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como vai ficar:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Material(
          color: cor,
          borderRadius: BorderRadius.circular(20),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Row(
              children: [
                Text(icone, style: const TextStyle(fontSize: 52)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tituloExibido,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: titulo.isEmpty ? 0.7 : 1,
                          ),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          fontStyle: titulo.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (descricao.isNotEmpty) ...[
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeletorCor extends StatelessWidget {
  final List<Color> cores;
  final Color selecionada;
  final ValueChanged<Color> aoSelecionar;

  const _SeletorCor({
    required this.cores,
    required this.selecionada,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cores.map((c) {
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
      }).toList(),
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
