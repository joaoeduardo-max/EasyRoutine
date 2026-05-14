import 'package:flutter/material.dart';
import 'tarefa.dart';

class Rotina {
  final String id;
  final String titulo;
  final String? descricao;
  final String cor;
  final String icone;
  final bool ativa;
  final DateTime criadaEm;
  final DateTime atualizadaEm;

  final int totalTarefas;

  final List<Tarefa>? tarefas;

  Rotina({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.icone,
    required this.ativa,
    required this.criadaEm,
    required this.atualizadaEm,
    required this.totalTarefas,
    this.tarefas,
  });

  Rotina semTarefas() => Rotina(
        id: id,
        titulo: titulo,
        descricao: descricao,
        cor: cor,
        icone: icone,
        ativa: ativa,
        criadaEm: criadaEm,
        atualizadaEm: atualizadaEm,
        totalTarefas: totalTarefas,
      );

  int? get duracaoTotalMinutos {
    final lista = tarefas;
    if (lista == null) return null;
    final somatorio = lista
        .map((t) => t.duracaoMinutos ?? 0)
        .fold<int>(0, (a, b) => a + b);
    return somatorio == 0 ? null : somatorio;
  }

  Color get corFlutter {
    final hex = cor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory Rotina.fromJson(Map<String, dynamic> json) {
    final tarefasJson = json['tarefas'] as List<dynamic>?;
    return Rotina(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      cor: json['cor'] as String,
      icone: json['icone'] as String,
      ativa: json['ativa'] as bool,
      criadaEm: DateTime.parse(json['criadaEm'] as String),
      atualizadaEm: DateTime.parse(json['atualizadaEm'] as String),
      totalTarefas: (json['totalTarefas'] as num?)?.toInt() ?? 0,
      tarefas: tarefasJson
          ?.map((e) => Tarefa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
