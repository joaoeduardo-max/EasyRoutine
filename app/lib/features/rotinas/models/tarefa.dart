class Tarefa {
  final String id;
  final String rotinaId;
  final String titulo;
  final int ordem;
  final int? duracaoMinutos;
  final String? horario;
  final String? cor;
  final String icone;
  final bool concluida;

  Tarefa({
    required this.id,
    required this.rotinaId,
    required this.titulo,
    required this.ordem,
    required this.duracaoMinutos,
    required this.horario,
    required this.cor,
    required this.icone,
    required this.concluida,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] as String,
      rotinaId: json['rotinaId'] as String,
      titulo: json['titulo'] as String,
      ordem: json['ordem'] as int,
      duracaoMinutos: json['duracaoMinutos'] as int?,
      horario: json['horario'] as String?,
      cor: json['cor'] as String?,
      icone: json['icone'] as String,
      concluida: json['concluida'] as bool,
    );
  }
}
