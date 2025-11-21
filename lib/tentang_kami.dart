import 'package:flutter/material.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text('Tentang Kami'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Tentang Aplikasi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Text(
              "Aplikasi ini dibuat untuk membantu UMKM dan masyarakat "
              "dalam mengakses informasi, layanan, serta pengelolaan data "
              "secara cepat dan mudah.\n\n"
              "Dikembangkan oleh tim pengembang terbaik untuk mendukung "
              "kemajuan digital di Indonesia.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
