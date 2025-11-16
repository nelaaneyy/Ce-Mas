import 'package:flutter/material.dart';

class UmkmPage extends StatelessWidget {
  const UmkmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UMKM'), // Sesuai desain
      ),
      body: const Center(
        child: Text('Ini Halaman Daftar UMKM'),
      ),
    );
  }
}