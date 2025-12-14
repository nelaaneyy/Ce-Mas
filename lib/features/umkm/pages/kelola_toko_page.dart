import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';
import 'package:cemas/features/umkm/pages/form_produk_page.dart';

class KelolaTokoPage extends StatefulWidget {
  const KelolaTokoPage({super.key});

  @override
  State<KelolaTokoPage> createState() => _KelolaTokoPageState();
}

class _KelolaTokoPageState extends State<KelolaTokoPage> {
  final SellerService _sellerService = SellerService();
  
  // Variabel untuk menyimpan pesan notifikasi
  String? _successMessage;

  // Fungsi untuk menampilkan banner selama 3 detik
  void _showSuccessBanner(String message) {
    setState(() {
      _successMessage = message;
    });
    // Hilangkan otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _successMessage = null;
        });
      }
    });
  }

  // Fungsi Navigasi ke Form (Tambah/Edit)
  void _navigateToForm({String? productId, Map<String, dynamic>? data}) async {
    // Kita pakai 'await' untuk menunggu hasil dari halaman sebelah
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => FormProdukPage(productId: productId, productData: data),
      ),
    );

    // Cek hasil balikan
    if (result == 'added') {
      _showSuccessBanner("Berhasil menambah produk!");
    } else if (result == 'edited') {
      _showSuccessBanner("Produk berhasil di edit!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Kelola Produk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: _sellerService.getMyStoreStream(),
        builder: (context, storeSnapshot) {
          // Loading state
          if (storeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if store exists
          if (!storeSnapshot.hasData || !storeSnapshot.data!.exists) {
            return const Center(
              child: Text("Data toko tidak ditemukan"),
            );
          }

          // Get store data and check verification status
          var storeData = storeSnapshot.data!.data() as Map<String, dynamic>;
          String status = storeData['status'] ?? 'Menunggu';
          bool isVerified = status == 'Terverifikasi';

          // If not verified, show locked UI
          if (!isVerified) {
            return Column(
              children: [
                // Header
                Container(
                  color: Colors.blue.shade800,
                  width: double.infinity,
                  height: 20,
                ),
                
                // Locked Message
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 100,
                            color: status == 'Ditolak' ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            status == 'Ditolak' 
                                ? 'Verifikasi Ditolak'
                                : 'Menunggu Verifikasi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: status == 'Ditolak' ? Colors.red : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            status == 'Ditolak'
                                ? 'Toko Anda ditolak oleh admin.\nSilakan hubungi admin untuk informasi lebih lanjut.'
                                : 'Toko Anda sedang dalam proses verifikasi oleh admin.\nAnda dapat mengelola produk setelah toko terverifikasi.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade800),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Proses verifikasi biasanya memakan waktu 1-2 hari kerja.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // If verified, show normal product management UI
          return Column(
            children: [
              // --- HEADER BIRU ---
              Container(
                color: Colors.blue.shade800,
                width: double.infinity,
                height: 20,
              ),

              // --- AREA NOTIFIKASI & PENCARIAN ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 1. BANNER SUKSES
                    if (_successMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                    // 2. SEARCH BAR
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Cari produk",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 3. TOMBOL TAMBAH PRODUK
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToForm(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Tambah Produk", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // --- LIST PRODUK ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _sellerService.getMyProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 80, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text("Error memuat produk", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Belum ada produk", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    var products = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        var data = product.data() as Map<String, dynamic>;

                        return _buildProductCard(product.id, data);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU PRODUK ---
  Widget _buildProductCard(String productId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[100],
              child: (data['fotoProduk'] != null && data['fotoProduk'] != '')
                  ? Image.network(data['fotoProduk'], fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),

          // Info Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['namaProduk'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Rp ${data['harga']}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),

          // Tombol Aksi
          Column(
            children: [
              // Edit Button
              InkWell(
                onTap: () => _navigateToForm(productId: productId, data: data), // Panggil fungsi navigasi baru
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text("Edit", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Hapus Button
              InkWell(
                onTap: () => _showDeleteDialog(productId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text("Hapus", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- DIALOG HAPUS ---
  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Placeholder visual
              const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                "Anda yakin ingin menghapus produk ini?",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        await _sellerService.deleteProduct(productId);
                        Navigator.pop(ctx); // Tutup Dialog
                        _showSuccessBanner("Data berhasil dihapus!"); // TAMPILKAN BANNER
                      },
                      child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}