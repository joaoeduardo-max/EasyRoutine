import '../../core/api/dio_client.dart';
import 'models/usuario.dart';

class ResultadoAuth {
  final String token;
  final Usuario usuario;
  ResultadoAuth({required this.token, required this.usuario});
}

class AuthService {
  final _dio = DioClient.instancia.dio;

  Future<ResultadoAuth> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final resp = await _dio.post('/auth/registrar', data: {
        'nome': nome,
        'email': email,
        'senha': senha,
      });
      return _parseAutenticacao(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<ResultadoAuth> login({
    required String email,
    required String senha,
  }) async {
    try {
      final resp = await _dio.post('/auth/login', data: {
        'email': email,
        'senha': senha,
      });
      return _parseAutenticacao(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Usuario> me() async {
    try {
      final resp = await _dio.get('/auth/me');
      final dados = resp.data as Map<String, dynamic>;
      return Usuario.fromJson(dados['usuario'] as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  ResultadoAuth _parseAutenticacao(Map<String, dynamic> dados) {
    return ResultadoAuth(
      token: dados['token'] as String,
      usuario: Usuario.fromJson(dados['usuario'] as Map<String, dynamic>),
    );
  }
}
