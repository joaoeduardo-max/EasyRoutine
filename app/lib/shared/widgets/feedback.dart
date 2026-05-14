import 'package:flutter/material.dart';

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
