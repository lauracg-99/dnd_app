import 'package:flutter/material.dart';

class FeatsScreen extends StatelessWidget {
  const FeatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Feats Screen\n\nThis is where feats will be displayed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
