import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UmkmListTile extends StatelessWidget {
  final DocumentSnapshot sellerData;
  const UmkmListTile({super.key, required this.sellerData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari dokumen seller
    String namaToko = sellerData['namaToko'] ?? 'Nama Toko';
    String alamat = sellerData['alamat'] ?? 'Alamat';
    String fotoToko = sellerData['fotoToko'] ?? '';
    
    // Data ini belum ada di skema kita, jadi kita hardcode untuk UI
    String rating = "4.8";
    String ulasan = "(10 ulasan)";

    return Card(
      // Atur margin agar ada jarak
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: () {
          // TODO: Navigasi ke halaman detail UMKM
          print('Pindah ke detail: $namaToko');
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
              : Container( // Placeholder jika tidak ada foto
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
                Text(" $rating", style: const TextStyle(fontSize: 12)),
                Text(" $ulasan", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                Text(" $alamat", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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