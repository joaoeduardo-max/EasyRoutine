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
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _erro = null);
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.entrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const SizedBox(height: 16),
                const CabecalhoMarca(simboloTamanho: 56, fonteTamanho: 28),
                const SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Que bom te ver de\n',
                        style: AppTheme.frauncesRegular(
                          fontSize: 30,
                          color: AppColors.tinta,
                        ),
                      ),
                      TextSpan(
                        text: 'volta',
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
                  'Entre para continuar suas rotinas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textoFraco,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
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
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _entrar(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Informe sua senha' : null,
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  MensagemErro(mensagem: _erro!),
                ],
                const SizedBox(height: 32),
                BotaoGrande(
                  texto: 'Entrar',
                  carregando: auth.carregando,
                  aoTocar: _entrar,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: auth.carregando
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CadastroScreen(),
                            ),
                          ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textoFraco,
                          ),
                      children: const [
                        TextSpan(text: 'Não tem conta?  '),
                        TextSpan(
                          text: 'Criar conta',
                          style: TextStyle(
                            color: AppColors.coral,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
