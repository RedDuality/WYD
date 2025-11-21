import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logoimage.png',
          width: 150,
          height: 150, 
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
