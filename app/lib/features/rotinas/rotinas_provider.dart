import 'package:flutter/foundation.dart';
import 'models/rotina.dart';
import 'rotinas_service.dart';

class RotinasProvider extends ChangeNotifier {
  final RotinasService _service = RotinasService();

  List<Rotina> _rotinas = [];
  bool _carregando = false;
  bool _jaCarregou = false;

  List<Rotina> get rotinas => List.unmodifiable(_rotinas);
  bool get carregando => _carregando;
  bool get jaCarregou => _jaCarregou;
  bool get vazio => _rotinas.isEmpty;

  Future<void> carregar() async {
    _setCarregando(true);
    try {
      _rotinas = await _service.listar();
      _jaCarregou = true;
    } finally {
      _setCarregando(false);
    }
  }

  Future<Rotina> criar({
    required String titulo,
    String? descricao,
    required String cor,
    required String icone,
    Periodo? periodo,
  }) async {
    final nova = await _service.criar(
      titulo: titulo,
      descricao: descricao,
      cor: cor,
      icone: icone,
      periodo: periodo,
    );
    _rotinas = [nova, ..._rotinas];
    notifyListeners();
    return nova;
  }

  Future<Rotina> atualizar(
    String id, {
    required String titulo,
    required String? descricao,
    required String cor,
    required String icone,
    required Periodo? periodo,
  }) async {
    final atualizada = await _service.atualizar(
      id,
      titulo: titulo,
      descricao: descricao,
      cor: cor,
      icone: icone,
      periodo: periodo,
    );
    final idx = _rotinas.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _rotinas = List.of(_rotinas)..[idx] = atualizada.semTarefas();
      notifyListeners();
    }
    return atualizada;
  }

  Future<void> excluir(String id) async {
    await _service.excluir(id);
    _rotinas = _rotinas.where((r) => r.id != id).toList();
    notifyListeners();
  }

  void atualizarRotinaLocal(Rotina nova) {
    final idx = _rotinas.indexWhere((r) => r.id == nova.id);
    if (idx == -1) return;
    final atual = _rotinas[idx];
    final mudou = atual.totalTarefas != nova.totalTarefas ||
        atual.titulo != nova.titulo ||
        atual.descricao != nova.descricao ||
        atual.cor != nova.cor ||
        atual.icone != nova.icone ||
        atual.periodo != nova.periodo;
    if (!mudou) return;
    _rotinas = List.of(_rotinas)..[idx] = nova.semTarefas();
    notifyListeners();
  }

  void limpar() {
    _rotinas = [];
    _jaCarregou = false;
    _carregando = false;
    notifyListeners();
  }

  void _setCarregando(bool valor) {
    _carregando = valor;
    notifyListeners();
  }
}
