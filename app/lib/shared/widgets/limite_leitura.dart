import 'package:flutter/material.dart';

class LimiteLeitura extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const LimiteLeitura({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
