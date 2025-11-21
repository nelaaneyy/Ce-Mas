import 'package:flutter/material.dart';

class NilaiUmkmBerhasilPage extends StatelessWidget {
  final String umkmNama;

  const NilaiUmkmBerhasilPage({super.key, required this.umkmNama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("Nilai UMKM"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            const Icon(Icons.check_circle,
                color: Colors.green, size: 80),

            const SizedBox(height: 20),

            Text(
              "Terima Kasih",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Ulasan Anda berhasil dikirim.\n"
              "Terima kasih telah mendukung UMKM $umkmNama "
              "untuk terus berkembang!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Kembali
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade800),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  child: Text(
                    "Kembali",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol Lihat UMKM
                ElevatedButton(
                  onPressed: () {
                    // TODO : Pindah ke profil UMKM
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  child: const Text(
                    "Lihat UMKM",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
