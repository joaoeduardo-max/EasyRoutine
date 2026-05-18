import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesProvider extends ChangeNotifier {
  static const _chaveVibracao = 'config.vibracao';
  static const _chaveEscalaFonte = 'config.escalaFonte';

  static const List<double> escalasDisponiveis = [1.0, 1.2, 1.4];

  bool _vibracaoLigada = true;
  double _escalaFonte = 1.0;
  bool _carregado = false;

  bool get vibracaoLigada => _vibracaoLigada;
  double get escalaFonte => _escalaFonte;
  bool get carregado => _carregado;

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _vibracaoLigada = prefs.getBool(_chaveVibracao) ?? true;
    final escala = prefs.getDouble(_chaveEscalaFonte) ?? 1.0;
    _escalaFonte = escalasDisponiveis.contains(escala) ? escala : 1.0;
    _carregado = true;
    notifyListeners();
  }

  Future<void> definirVibracao(bool valor) async {
    if (_vibracaoLigada == valor) return;
    _vibracaoLigada = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveVibracao, valor);
  }

  Future<void> definirEscalaFonte(double valor) async {
    if (!escalasDisponiveis.contains(valor) || _escalaFonte == valor) return;
    _escalaFonte = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_chaveEscalaFonte, valor);
  }
}
