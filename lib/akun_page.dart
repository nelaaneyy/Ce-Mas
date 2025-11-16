import 'package:flutter/material.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
      ),
      body: const Center(
        child: Text('Ini Halaman Akun'),
      ),
    );
  }
}