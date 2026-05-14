import 'package:flutter/foundation.dart';
import '../../core/api/api_exception.dart';
import '../../core/storage/token_storage.dart';
import 'auth_service.dart';
import 'models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  Usuario? _usuario;
  bool _carregando = false;
  bool _inicializou = false;

  Usuario? get usuario => _usuario;
  bool get carregando => _carregando;
  bool get inicializou => _inicializou;
  bool get autenticado => _usuario != null;

  Future<void> inicializar() async {
    final token = await _tokenStorage.ler();
    if (token == null || token.isEmpty) {
      _inicializou = true;
      notifyListeners();
      return;
    }
    try {
      _usuario = await _service.me();
    } catch (_) {

      _usuario = null;
      await _tokenStorage.remover();
    } finally {
      _inicializou = true;
      notifyListeners();
    }
  }

  Future<void> entrar({required String email, required String senha}) async {
    _setCarregando(true);
    try {
      final r = await _service.login(email: email, senha: senha);
      await _tokenStorage.salvar(r.token);
      _usuario = r.usuario;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _setCarregando(true);
    try {
      final r = await _service.registrar(nome: nome, email: email, senha: senha);
      await _tokenStorage.salvar(r.token);
      _usuario = r.usuario;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> sair() async {
    await _tokenStorage.remover();
    zerar();
  }

  void zerar() {
    if (_usuario == null) return;
    _usuario = null;
    notifyListeners();
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }

  static String mensagemDeErro(Object e) {
    if (e is ApiException) return e.mensagem;
    return 'Algo deu errado. Tente novamente.';
  }
}
