import 'package:flutter/material.dart';

import 'core/theme.dart';

class HeroApp extends StatelessWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const Scaffold(body: Center(child: Text('Hero is running'))),
    );
  }
}
