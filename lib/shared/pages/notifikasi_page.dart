import 'package:flutter/material.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cemas/shared/pages/detail_notifikasi_page.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifikasi = [
      {
        "waktu": "11:00, 12 Nov 2025",
        "pesan": "Beri ulasan terhadap UMKM!",
        "umkm": "Bakso Pak Budi",
        "dibaca": false,
      },
      {
        "waktu": "09:05, 14 Nov 2025",
        "pesan": "UMKM baru tersedia!",
        "umkm": "Sate Enak Barokah",
        "dibaca": false,
      },
      {
        "waktu": "20:14, 13 Nov 2025",
        "pesan": "Pembaruan tersedia!",
        "umkm": "Warung Mamah",
        "dibaca": true,
      },
      {
        "waktu": "11:00, 12 Nov 2025",
        "pesan": "Anda berhasil login",
        "umkm": "",
        "dibaca": true,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        title: const Text("Notifikasi"),
        elevation: 0,
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        itemCount: notifikasi.length,
        itemBuilder: (context, index) {
          final item = notifikasi[index];

          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceLG),
            padding: const EdgeInsets.all(AppTheme.spaceLG),
            decoration: AppTheme.cardDecoration(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waktu + titik merah
                Row(
                  children: [
                    Text(
                      item["waktu"],
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(width: AppTheme.spaceSM),
                    if (!item["dibaca"])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceSM),

                // Pesan
                Text(
                  item["pesan"],
                  style: AppTheme.labelBold.copyWith(
                    fontSize: 16,
                    fontWeight: item["dibaca"] ? FontWeight.w600 : FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppTheme.spaceMD),

                // Tombol tindakan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNotifikasiPage(
                            waktu: item["waktu"],
                            pesan: item["pesan"],
                            umkmNama: item["umkm"],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.backgroundWhite,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Lihat Notifikasi",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
