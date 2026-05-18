import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/botao_grande.dart';
import '../../../shared/widgets/cabecalho_marca.dart';
import '../../../shared/widgets/campo_senha.dart';
import '../../../shared/widgets/limite_leitura.dart';
import '../../../shared/widgets/mensagem_erro.dart';
import '../auth_provider.dart';
import '../../rotinas/screens/home_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() => _erro = null);
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = AuthProvider.mensagemDeErro(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: LimiteLeitura(
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    tooltip: 'Voltar',
                    onPressed: auth.carregando
                        ? null
                        : () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(height: 8),
                const CabecalhoMarca(simboloTamanho: 56, fonteTamanho: 28),
                const SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Vamos criar sua\n',
                        style: AppTheme.frauncesRegular(
                          fontSize: 30,
                          color: AppColors.tinta,
                        ),
                      ),
                      TextSpan(
                        text: 'conta',
                        style: AppTheme.frauncesItalic(
                          fontSize: 30,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'É rápido e direto.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textoFraco,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Informe seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe seu email';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoSenha(
                  controller: _senhaController,
                  label: 'Senha',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'A senha precisa de pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoSenha(
                  controller: _confirmarController,
                  label: 'Confirmar senha',
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _cadastrar(),
                  validator: (v) {
                    if (v != _senhaController.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  MensagemErro(mensagem: _erro!),
                ],
                const SizedBox(height: 32),
                BotaoGrande(
                  texto: 'Criar conta',
                  carregando: auth.carregando,
                  aoTocar: _cadastrar,
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
