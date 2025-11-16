import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold di sini agar setiap halaman bisa punya AppBar sendiri
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        // Nanti kita custom AppBar ini seperti desainmu
      ),
      body: const Center(
        child: Text('Ini Halaman Beranda'),
      ),
    );
  }
}