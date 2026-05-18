import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../../auth/auth_provider.dart';
import '../../perfil/screens/perfil_screen.dart';
import '../models/rotina.dart';
import '../rotinas_provider.dart';
import '../widgets/rotina_card.dart';
import 'detalhes_rotina_screen.dart';
import 'form_rotina_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RotinasProvider>();
      if (!provider.jaCarregou && !provider.carregando) {
        provider.carregar().catchError((e) => _mostrarErro(e));
      }
    });
  }

  void _mostrarErro(Object e) {
    if (!mounted) return;
    mostrarSnack(context, e.toString());
  }

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PerfilScreen()),
    );
  }

  Future<void> _confirmarExclusao(Rotina rotina) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir rotina?'),
        content: Text('"${rotina.titulo}" será removida.'),
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
      await context.read<RotinasProvider>().excluir(rotina.id);
      if (!mounted) return;
      mostrarSnack(context, 'Rotina excluída');
    } catch (e) {
      _mostrarErro(e);
    }
  }

  Future<void> _abrirCriar() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FormRotinaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final rotinasProvider = context.watch<RotinasProvider>();

    return Scaffold(
      body: SafeArea(
        child: LimiteLeitura(
          child: Column(
            children: [
              _Header(
                nome: usuario?.nome,
                aoAbrirPerfil: _abrirPerfil,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      rotinasProvider.carregar().catchError(_mostrarErro),
                  child: _construirCorpo(rotinasProvider),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCriar,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Nova rotina',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _construirCorpo(RotinasProvider provider) {
    if (provider.carregando && !provider.jaCarregou) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.vazio) {
      return _estadoVazio();
    }
    final secoes = _agrupar(provider.rotinas);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: secoes.length,
      itemBuilder: (_, i) {
        final secao = secoes[i];
        return Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 24),
          child: _SecaoRotinas(
            titulo: secao.titulo,
            emoji: secao.emoji,
            rotinas: secao.rotinas,
            aoTocar: (r) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DetalhesRotinaScreen(rotinaId: r.id),
              ),
            ),
            aoSegurar: _confirmarExclusao,
          ),
        );
      },
    );
  }

  List<_Secao> _agrupar(List<Rotina> rotinas) {
    final mapa = <Periodo?, List<Rotina>>{};
    for (final r in rotinas) {
      mapa.putIfAbsent(r.periodo, () => []).add(r);
    }
    final ordem = <Periodo?>[Periodo.manha, Periodo.tarde, Periodo.noite, null];
    return [
      for (final p in ordem)
        if ((mapa[p] ?? const []).isNotEmpty)
          _Secao(
            periodo: p,
            titulo: p?.rotulo ?? 'Sem período definido',
            emoji: p?.emoji ?? '〰️',
            rotinas: mapa[p]!,
          ),
    ];
  }

  Widget _estadoVazio() {

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
      children: [
        Center(
          child: Opacity(
            opacity: 0.85,
            child: SvgPicture.asset(
              'assets/logos/symbol-color.svg',
              width: 120,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Você ainda não tem rotinas',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Toque em "Nova rotina" para criar a primeira.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Secao {
  final Periodo? periodo;
  final String titulo;
  final String emoji;
  final List<Rotina> rotinas;

  _Secao({
    required this.periodo,
    required this.titulo,
    required this.emoji,
    required this.rotinas,
  });
}

class _SecaoRotinas extends StatelessWidget {
  final String titulo;
  final String emoji;
  final List<Rotina> rotinas;
  final void Function(Rotina) aoTocar;
  final void Function(Rotina) aoSegurar;

  const _SecaoRotinas({
    required this.titulo,
    required this.emoji,
    required this.rotinas,
    required this.aoTocar,
    required this.aoSegurar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: AppTheme.frauncesRegular(
                  fontSize: 22,
                  color: AppColors.tinta,
                ),
              ),
            ],
          ),
        ),
        for (int i = 0; i < rotinas.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          RotinaCard(
            rotina: rotinas[i],
            aoTocar: () => aoTocar(rotinas[i]),
            aoSegurar: () => aoSegurar(rotinas[i]),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String? nome;
  final VoidCallback aoAbrirPerfil;

  const _Header({required this.nome, required this.aoAbrirPerfil});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Suas rotinas',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoFraco,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Olá, ',
                        style: AppTheme.frauncesRegular(
                          fontSize: 30,
                          color: AppColors.tinta,
                        ),
                      ),
                      TextSpan(
                        text: nome ?? 'você',
                        style: AppTheme.frauncesItalic(
                          fontSize: 30,
                          color: AppColors.coral,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: AppTheme.frauncesRegular(
                          fontSize: 30,
                          color: AppColors.tinta,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            iconSize: 28,
            tooltip: 'Perfil',
            onPressed: aoAbrirPerfil,
          ),
        ],
      ),
    );
  }
}
