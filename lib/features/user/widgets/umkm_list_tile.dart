import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/features/user/pages/detail_toko_page.dart'; // Import untuk navigasi

class UmkmListTile extends StatelessWidget {
  final DocumentSnapshot sellerData;
  const UmkmListTile({super.key, required this.sellerData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari dokumen seller
    final data = sellerData.data() as Map<String, dynamic>;
    String namaToko = data['namaToko'] ?? 'Nama Toko';
    String alamat = data['alamat'] ?? 'Alamat';
    String fotoToko = data['fotoToko'] ?? '';

    // Ambil rating dan jumlah ulasan dari Firestore
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final jumlahUlasan = data['jumlahUlasan'] ?? 0;
    String ratingStr = rating.toStringAsFixed(1);
    String ulasan = "($jumlahUlasan ulasan)";

    return Card(
      // Atur margin agar ada jarak
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: () {
          // Navigasi ke halaman detail UMKM dengan mengirim data seller
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTokoPage(sellerData: sellerData),
            ),
          );
        },
        // 1. Gambar di Kiri
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: (fotoToko.isNotEmpty)
              ? Image.network(
                  fotoToko,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Container(
                  // Placeholder jika tidak ada foto
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store, color: Colors.grey),
                ),
        ),

        // 2. Judul
        title: Text(
          namaToko,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // 3. Subtitle (Rating & Lokasi)
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(" $ratingStr", style: const TextStyle(fontSize: 12)),
                Text(
                  " $ulasan",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                Text(
                  " $alamat",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        // 4. Panah di Kanan
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
