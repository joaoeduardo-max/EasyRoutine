import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../../auth/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../configuracoes/screens/configuracoes_screen.dart';
import '../../rotinas/rotinas_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String _formatarData(DateTime d) {
    final local = d.toLocal();
    return '${local.day} de ${_meses[local.month - 1]} de ${local.year}';
  }

  Future<void> _confirmarSair(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente da próxima vez.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    final rotinas = context.read<RotinasProvider>();
    await auth.sair();
    rotinas.limpar();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final qtdRotinas = context.watch<RotinasProvider>().rotinas.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: LimiteLeitura(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              _Avatar(nome: usuario?.nome),
              const SizedBox(height: 24),
              _CartaoInfo(
                icone: Icons.person_outline,
                rotulo: 'Nome',
                valor: usuario?.nome ?? '—',
              ),
              const SizedBox(height: 12),
              _CartaoInfo(
                icone: Icons.email_outlined,
                rotulo: 'Email',
                valor: usuario?.email ?? '—',
              ),
              const SizedBox(height: 12),
              _CartaoInfo(
                icone: Icons.calendar_today_outlined,
                rotulo: 'Conta criada em',
                valor: usuario != null ? _formatarData(usuario.criadoEm) : '—',
              ),
              const SizedBox(height: 12),
              _CartaoInfo(
                icone: Icons.checklist_rounded,
                rotulo: 'Rotinas cadastradas',
                valor: qtdRotinas.toString(),
              ),
              const SizedBox(height: 32),
              _AcaoTile(
                icone: Icons.tune_rounded,
                rotulo: 'Configurações',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConfiguracoesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarSair(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.erro),
                  label: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      color: AppColors.erro,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.erro, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'EasyRoutine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textoFraco,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? nome;
  const _Avatar({required this.nome});

  String _iniciais() {
    final n = nome?.trim() ?? '';
    if (n.isEmpty) return '?';
    final partes = n.split(RegExp(r'\s+'));
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            _iniciais(),
            style: const TextStyle(
              color: AppColors.papel,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          nome ?? 'Visitante',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textoForte,
          ),
        ),
      ],
    );
  }
}

class _AcaoTile extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback aoTocar;

  const _AcaoTile({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.nevoa, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: AppColors.coral, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoForte,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textoFraco,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _CartaoInfo({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nevoa, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: AppColors.coral, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoFraco,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoForte,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
