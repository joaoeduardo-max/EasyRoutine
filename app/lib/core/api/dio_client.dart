import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.ler();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_ehTentativaDeLogin(error.requestOptions.path)) {

            await _tokenStorage.remover();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  void Function()? onUnauthorized;

  static bool _ehTentativaDeLogin(String path) {
    return path == '/auth/login' || path == '/auth/registrar';
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static final DioClient instancia = DioClient._internal();

  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Dio get dio => _dio;

  static ApiException traduzirErro(Object erro) {
    if (erro is! DioException) {
      return ApiException('Algo deu errado. Tente novamente.');
    }

    final status = erro.response?.statusCode;
    final dados = erro.response?.data;

    if (dados is Map && dados['mensagem'] is String) {
      return ApiException(dados['mensagem'] as String, status: status);
    }

    switch (erro.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'A rede está lenta. Verifique sua conexão e tente de novo.',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Sem conexão com o servidor. Verifique sua internet.',
        );
      case DioExceptionType.cancel:
        return ApiException('Operação cancelada.');
      default:
        if (status != null && status >= 500) {
          return ApiException(
            'O servidor está com problema agora. Tente em alguns minutos.',
            status: status,
          );
        }
        return ApiException(
          'Não foi possível concluir a operação.',
          status: status,
        );
    }
  }
}
