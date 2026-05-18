import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/configuracoes/configuracoes_provider.dart';

enum TipoVibracao { selecao, leve, media, pesada }

void vibrar(BuildContext context, [TipoVibracao tipo = TipoVibracao.selecao]) {
  final config = context.read<ConfiguracoesProvider>();
  if (!config.vibracaoLigada) return;
  switch (tipo) {
    case TipoVibracao.selecao:
      HapticFeedback.selectionClick();
    case TipoVibracao.leve:
      HapticFeedback.lightImpact();
    case TipoVibracao.media:
      HapticFeedback.mediumImpact();
    case TipoVibracao.pesada:
      HapticFeedback.heavyImpact();
  }
}

void mostrarSnack(BuildContext context, String mensagem) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(mensagem),
      duration: const Duration(seconds: 6),
    ),
  );
}
