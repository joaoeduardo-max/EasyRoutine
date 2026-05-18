import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../auth_provider.dart';
import 'login_screen.dart';
import '../../rotinas/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final auth = context.read<AuthProvider>();
    await auth.inicializar();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => auth.autenticado ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logos/logo-vertical-color.svg',
                width: 220,
              ),
              const SizedBox(height: 16),
              Text(
                'Um passo de cada vez.',
                style: AppTheme.frauncesItalic(
                  fontSize: 18,
                  color: AppColors.textoFraco,
                ),
              ),
              const SizedBox(height: 56),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.tinta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
