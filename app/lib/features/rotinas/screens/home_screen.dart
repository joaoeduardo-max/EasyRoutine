import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/feedback.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../../auth/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
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

  Future<void> _confirmarSair() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você precisará entrar novamente da próxima vez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    await _sair();
  }

  Future<void> _sair() async {
    final auth = context.read<AuthProvider>();
    final rotinas = context.read<RotinasProvider>();
    await auth.sair();
    rotinas.limpar();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
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
                aoSair: _confirmarSair,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      rotinasProvider.carregar().catchError(_mostrarErro),
                  child: _construirCorpo(rotinasProvider, usuario?.nome),
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

  Widget _construirCorpo(RotinasProvider provider, String? nome) {
    if (provider.carregando && !provider.jaCarregou) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.vazio) {
      return _estadoVazio();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: provider.rotinas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final r = provider.rotinas[i];
        return RotinaCard(
          rotina: r,
          aoTocar: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalhesRotinaScreen(rotinaId: r.id),
            ),
          ),
          aoSegurar: () => _confirmarExclusao(r),
        );
      },
    );
  }

  Widget _estadoVazio() {

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      children: [
        const Center(
          child: Text('📋', style: TextStyle(fontSize: 110)),
        ),
        const SizedBox(height: 24),
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

class _Header extends StatelessWidget {
  final String? nome;
  final VoidCallback aoSair;

  const _Header({required this.nome, required this.aoSair});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nome != null ? 'Olá, $nome!' : 'Olá!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textoForte,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suas rotinas',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textoFraco,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            iconSize: 26,
            tooltip: 'Sair',
            onPressed: aoSair,
          ),
        ],
      ),
    );
  }
}
