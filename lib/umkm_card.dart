import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_toko_page.dart'; // Pastikan import ini ada

class UmkmCard extends StatelessWidget {
  final DocumentSnapshot sellerData;

  const UmkmCard({super.key, required this.sellerData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari Firestore
    String namaToko = sellerData['namaToko'] ?? 'Nama Toko';
    String alamat = sellerData['alamat'] ?? 'Alamat';
    String fotoToko = sellerData['fotoToko'] ?? ''; // URL foto

    // Data Rating & Ulasan BELUM ADA di skema kita,
    // jadi kita hardcode dulu untuk UI
    String rating = "4.8";
    String ulasan = "(10 ulasan)";
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell( // TAMBAHAN: Agar kartu bisa diklik
        borderRadius: BorderRadius.circular(10), // Agar efek klik mengikuti bentuk kartu
        onTap: () {
          // --- NAVIGASI KE DETAIL TOKO ---
          Navigator.push(
            context,
            MaterialPageRoute(
              // Kita kirim data 'sellerData' ini ke halaman detail
              builder: (context) => DetailTokoPage(sellerData: sellerData),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              // Tampilkan fotoToko jika ada, jika tidak, tampilkan placeholder
              child: (fotoToko.isNotEmpty)
                  ? Image.network(
                      fotoToko,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.store, color: Colors.grey, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaToko,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
            )
          ],
        ),
      ),
    );
  }
}