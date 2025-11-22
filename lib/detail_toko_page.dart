import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTokoPage extends StatefulWidget {
  final DocumentSnapshot sellerData; // Data toko yang dikirim dari halaman sebelumnya

  const DetailTokoPage({super.key, required this.sellerData});

  @override
  State<DetailTokoPage> createState() => _DetailTokoPageState();
}

class _DetailTokoPageState extends State<DetailTokoPage> {
  
  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWA(String number, String message) async {
    // Format nomor (ganti 0 di depan dengan 62)
    if (number.startsWith('0')) {
      number = '62${number.substring(1)}';
    }
    
    final Uri url = Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak bisa membuka WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari widget
    var data = widget.sellerData.data() as Map<String, dynamic>;
    String sellerId = widget.sellerData.id; // ID Toko untuk ambil produk

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // --- 1. HEADER GAMBAR TOKO ---
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: Colors.blue.shade800,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(data['namaToko'], style: const TextStyle(color: Colors.white, fontSize: 16)),
              background: (data['fotoToko'] != null && data['fotoToko'] != '')
                  ? Image.network(data['fotoToko'], fit: BoxFit.cover)
                  : Container(color: Colors.blue.shade300, child: const Icon(Icons.store, size: 80, color: Colors.white)),
            ),
          ),

          // --- 2. INFO TOKO ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(data['kategori'] ?? 'Umum'),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade800),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.green),
                        onPressed: () {
                          _launchWA(data['noWhatsapp'], "Halo ${data['namaToko']}, saya mau tanya stok...");
                        },
                        tooltip: "Chat Penjual",
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(child: Text(data['alamat'] ?? '-', style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(data['deskripsi'] ?? 'Tidak ada deskripsi.', style: const TextStyle(fontSize: 14)),
                  const Divider(height: 30),
                  const Text("Daftar Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // --- 3. DAFTAR PRODUK (GRID) ---
          StreamBuilder<QuerySnapshot>(
            // Query: Ambil produk yang sellerId-nya sama dengan toko ini
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('sellerId', isEqualTo: sellerId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("Toko ini belum upload produk.")),
                  ),
                );
              }

              var products = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var prodData = products[index].data() as Map<String, dynamic>;
                      return _buildProductCard(prodData, data['noWhatsapp']);
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> prodData, String sellerWA) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: (prodData['fotoProduk'] != null && prodData['fotoProduk'] != '')
                  ? Image.network(prodData['fotoProduk'], width: double.infinity, fit: BoxFit.cover)
                  : Container(color: Colors.grey[100], child: const Center(child: Icon(Icons.fastfood, color: Colors.grey))),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prodData['namaProduk'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp ${prodData['harga']}", style: TextStyle(color: Colors.blue.shade800, fontSize: 12)),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _launchWA(sellerWA, "Halo, saya mau pesan ${prodData['namaProduk']}...");
                    },
                    child: const Text("Beli (WA)", style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}