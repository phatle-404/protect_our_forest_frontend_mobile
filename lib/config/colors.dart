import 'dart:ui';
import 'package:flutter/material.dart';

final Color buttonPrimaryColor = Color(0xFF89E8AC);
final Color buttonSecondaryColor = Color(0xFF2F6563);
final Color colorHeader = Color(0xFF1b3b3a);
final Color buttonExit = Color(0xFFE88989);
final Color locationMapColor = Color(0xFFFF6464);
final Color forestMapColor = Color(0xff91B284);

final Color weatherTheme = Color(0xff6495ED);
final Color sunColor = Color(0xFFFBFF00);

final Color white = Color(0xFFFFFFFF);
final Color black = Color(0xFF000000);

final Color homeBackgroundColor = Color(0xffFFF8E1);

final Color locationColor = Color(0xff00FF0D);
final Color appBarColor = Color(0xff1b3b3a);

class ForestBackground extends StatelessWidget {
  final Widget child;

  const ForestBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFF8E1), Color(0xFFA5D6A7)],
          ),
        ),
        child: child,
      ),
    );
  }
}
