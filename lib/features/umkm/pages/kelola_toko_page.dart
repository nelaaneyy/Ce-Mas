import 'package:cemas/features/umkm/pages/form_produk_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class KelolaTokoPage extends StatefulWidget {
  const KelolaTokoPage({super.key});

  @override
  State<KelolaTokoPage> createState() => _KelolaTokoPageState();
}

class _KelolaTokoPageState extends State<KelolaTokoPage> {
  final SellerService _sellerService = SellerService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text("Kelola Produk"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormProdukPage()),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Produk", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _sellerService.getMyProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text(
                     "Belum ada produk",
                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     "Tekan tombol + untuk menambah produk jualanmu",
                     style: TextStyle(color: Colors.grey),
                   ),
                ],
              ),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final String id = doc.id;
              final String nama = data['namaProduk'] ?? 'Tanpa Nama';
              final double harga = (data['harga'] is num) ? (data['harga'] as num).toDouble() : 0.0;
              final String? foto = data['fotoProduk'];
              final String kategori = data['kategori'] ?? '-';
              
              return _buildProductCard(id, nama, harga, foto, kategori, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(String id, String nama, double harga, String? foto, String kategori, Map<String, dynamic> fullData) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (foto != null && foto.isNotEmpty) 
            ? Image.network(foto, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey, width: 60, height: 60, child: const Icon(Icons.image_not_supported)))
            : Container(color: Colors.grey[200], width: 60, height: 60, child: const Icon(Icons.image, color: Colors.grey)),
        ),
        title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(kategori, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(_currencyFormat.format(harga), style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormProdukPage(productId: id, initialData: fullData)),
              );
            } else if (val == 'delete') {
              _confirmDelete(id, nama);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id, String nama) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus produk '$nama'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _sellerService.deleteProduct(id);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus")));
                }
              } catch (e) {
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
                }
              }
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }
}
