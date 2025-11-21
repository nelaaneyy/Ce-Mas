import 'package:flutter/material.dart';

class DetailNotifikasiPage extends StatelessWidget {
  final String waktu;
  final String pesan;
  final String umkmNama;

  const DetailNotifikasiPage({
    super.key,
    required this.waktu,
    required this.pesan,
    required this.umkmNama,
  });

  @override
  Widget build(BuildContext context) {
    // --- VARIABEL DINAMIS ---
    String deskripsi = "";
    String button1 = "";
    String button2 = "";
    VoidCallback? onButton1;
    VoidCallback? onButton2;

    // --- LOGIKA NOTIFIKASI BERDASARKAN JUDUL ---
    if (pesan == "Beri ulasan terhadap UMKM!") {
      deskripsi = "Anda baru saja melakukan transaksi di UMKM $umkmNama. "
                  "Bantu UMKM berkembang dengan memberikan ulasan Anda.";

      button1 = "Nilai UMKM";
      button2 = "Lihat UMKM";

      onButton1 = () {
        Navigator.pushNamed(context, "/nilai_umkm");
      };

      onButton2 = () {
        Navigator.pushNamed(context, "/lihat_umkm");
      };
    }

    else if (pesan == "Pembaruan sistem tersedia!") {
      deskripsi =
          "Versi terbaru aplikasi telah tersedia. "
          "Perbarui sekarang untuk mendapatkan fitur terbaru.";

      button1 = "Perbarui Sekarang";
      button2 = "Nanti Saja";

      onButton1 = () {
        // buka playstore / halaman update
        print("Update sekarang");
      };

      onButton2 = () {
        Navigator.pop(context);
      };
    }

    else if (pesan == "UMKM baru tersedia!") {
      deskripsi =
          "UMKM baru bernama $umkmNama kini tersedia di aplikasi. "
          "Yuk lihat profil dan dukung UMKM lokal!";

      button1 = "Lihat UMKM";
      button2 = "Nanti Saja";

      onButton1 = () {
        Navigator.pushNamed(context, "/lihat_umkm");
      };

      onButton2 = () {
        Navigator.pop(context);
      };
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("Detail Notifikasi"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Waktu
            Text(
              waktu,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Judul
            Text(
              pesan,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi dinamis
            Text(
              deskripsi,
              style: const TextStyle(fontSize: 15),
            ),

            const Spacer(),

            // Tombol 1
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButton1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  button1,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tombol 2
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onButton2,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  button2,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
