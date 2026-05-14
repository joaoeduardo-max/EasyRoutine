class Usuario {
  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }
}
