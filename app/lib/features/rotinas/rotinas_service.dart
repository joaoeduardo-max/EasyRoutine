import '../../core/api/dio_client.dart';
import 'models/rotina.dart';
import 'models/tarefa.dart';

class RotinasService {
  final _dio = DioClient.instancia.dio;

  Future<List<Rotina>> listar() async {
    try {
      final resp = await _dio.get('/rotinas');
      final lista = resp.data as List<dynamic>;
      return lista
          .map((e) => Rotina.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Rotina> criar({
    required String titulo,
    String? descricao,
    required String cor,
    required String icone,
  }) async {
    try {
      final resp = await _dio.post('/rotinas', data: {
        'titulo': titulo,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
        'cor': cor,
        'icone': icone,
      });
      return Rotina.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Rotina> atualizar(
    String id, {
    required String titulo,
    required String? descricao,
    required String cor,
    required String icone,
  }) async {
    try {
      final resp = await _dio.put('/rotinas/$id', data: {
        'titulo': titulo,
        'descricao': descricao,
        'cor': cor,
        'icone': icone,
      });
      return Rotina.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _dio.delete('/rotinas/$id');
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Rotina> buscarDetalhes(String id) async {
    try {
      final resp = await _dio.get('/rotinas/$id');
      return Rotina.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Tarefa> adicionarTarefa(
    String rotinaId, {
    required String titulo,
    required String icone,
    int? duracaoMinutos,
  }) async {
    try {
      final resp = await _dio.post('/rotinas/$rotinaId/tarefas', data: {
        'titulo': titulo,
        'icone': icone,
        'duracaoMinutos': ?duracaoMinutos,
      });
      return Tarefa.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<Tarefa> atualizarTarefa(
    String tarefaId, {
    String? titulo,
    String? icone,
    int? duracaoMinutos,
    bool? duracaoExplicitamenteNula,
    bool? concluida,
  }) async {
    try {

      final body = <String, dynamic>{
        'titulo': ?titulo,
        'icone': ?icone,
        'duracaoMinutos': ?duracaoMinutos,

        if (duracaoExplicitamenteNula == true) 'duracaoMinutos': null,
        'concluida': ?concluida,
      };
      final resp = await _dio.put('/tarefas/$tarefaId', data: body);
      return Tarefa.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<void> excluirTarefa(String tarefaId) async {
    try {
      await _dio.delete('/tarefas/$tarefaId');
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }

  Future<List<Tarefa>> reordenarTarefas(
    String rotinaId,
    List<String> ordemIds,
  ) async {
    try {
      final resp = await _dio.put(
        '/rotinas/$rotinaId/reordenar',
        data: {'ordemIds': ordemIds},
      );
      final lista = resp.data as List<dynamic>;
      return lista
          .map((e) => Tarefa.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DioClient.traduzirErro(e);
    }
  }
}
