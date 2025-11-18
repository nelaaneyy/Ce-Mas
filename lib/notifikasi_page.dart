import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifikasi = [
      {
        "waktu": "11:00, 12 Nov 2025",
        "pesan": "Beri ulasan terhadap UMKM!",
        "dibaca": false,
      },
      {
        "waktu": "09:05, 14 Nov 2025",
        "pesan": "UMKM baru tersedia!",
        "dibaca": false,
      },
      {
        "waktu": "20:14, 13 Nov 2025",
        "pesan": "Pembaruan tersedia!",
        "dibaca": true,
      },
      {
        "waktu": "11:00, 12 Nov 2025",
        "pesan": "Anda berhasil login",
        "dibaca": true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("Notifikasi"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifikasi.length,
        itemBuilder: (context, index) {
          final item = notifikasi[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waktu + titik merah
                Row(
                  children: [
                    Text(
                      item["waktu"],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (!item["dibaca"])
                      const Icon(Icons.circle, size: 10, color: Colors.red),
                  ],
                ),

                const SizedBox(height: 8),

                // Pesan
                Text(
                  item["pesan"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol tindakan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Aksi ketika notifikasi dibuka
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lihat Notifikasi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
