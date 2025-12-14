import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/features/user/pages/detail_toko_page.dart'; // Pastikan import ini ada

class UmkmCard extends StatelessWidget {
  final DocumentSnapshot sellerData;

  const UmkmCard({super.key, required this.sellerData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari Firestore dengan aman
    final data = sellerData.data() as Map<String, dynamic>;
    String namaToko = data['namaToko'] ?? 'Nama Toko';
    String alamat = data['alamat'] ?? 'Alamat';
    // Fix field name match with SellerService (fotoUmkm instead of fotoToko)
    String fotoToko = data['fotoUmkm'] ?? data['fotoToko'] ?? '';

    // Get Real-Time Rating Data
    final num ratingNum = data['rating'] ?? 0;
    final double rating = ratingNum.toDouble();
    final int ulasan = data['jumlahUlasan'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell( 
        borderRadius: BorderRadius.circular(10), 
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTokoPage(sellerData: sellerData),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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
                      // RATING LOGIC
                      if (rating > 0) ...[
                        const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 18), // Amber[700]
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          " ($ulasan ulasan)",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            "Baru",
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700
                            ),
                          ),
                        ),
                      ],
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