import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _chave = 'auth_token';
  static const _storage = FlutterSecureStorage();

  Future<void> salvar(String token) => _storage.write(key: _chave, value: token);

  Future<String?> ler() => _storage.read(key: _chave);

  Future<void> remover() => _storage.delete(key: _chave);
}
