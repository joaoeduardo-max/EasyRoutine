import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/dio_client.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/rotinas/rotinas_provider.dart';

class EasyRoutineApp extends StatefulWidget {
  const EasyRoutineApp({super.key});

  @override
  State<EasyRoutineApp> createState() => _EasyRoutineAppState();
}

class _EasyRoutineAppState extends State<EasyRoutineApp> {
  @override
  void initState() {
    super.initState();
    DioClient.instancia.onUnauthorized = _aoDeslogar;
  }

  @override
  void dispose() {
    DioClient.instancia.onUnauthorized = null;
    super.dispose();
  }

  void _aoDeslogar() {
    final nav = AppNavigator.navigatorKey.currentState;
    final ctx = AppNavigator.navigatorKey.currentContext;
    if (nav == null || ctx == null) return;

    ctx.read<AuthProvider>().zerar();
    ctx.read<RotinasProvider>().limpar();

    nav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RotinasProvider()),
      ],
      child: MaterialApp(
        title: 'EasyRoutine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.tema,
        navigatorKey: AppNavigator.navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
