import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'kelola_toko_page.dart'; // Halaman List Produk (Gambar Kanan)

class DashboardTokoPage extends StatefulWidget {
  const DashboardTokoPage({super.key});

  @override
  State<DashboardTokoPage> createState() => _DashboardTokoPageState();
}

class _DashboardTokoPageState extends State<DashboardTokoPage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Kita ambil data Toko user ini secara Realtime
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('sellers').doc(_uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data toko tidak ditemukan"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Stack(
            children: [
              // 1. BACKGROUND BIRU (HEADER)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        // Header Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/logo_umkm.png', height: 30), // Logo kecil
                            const Row(
                              children: [
                                Icon(Icons.notifications_none, color: Colors.white),
                                SizedBox(width: 16),
                                Icon(Icons.person_outline, color: Colors.white),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Nama Toko
                        Text(
                          data['namaToko'] ?? 'Nama Toko',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. KONTEN UTAMA (SCROLLABLE)
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 160, left: 16, right: 16, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- STATISTIK (4 KOTAK) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // TODO: Ambil data real nanti (sementara dummy)
                          _buildStatItem("15", "Produk"),
                          _buildVerticalLine(),
                          _buildStatItem("120", "Dilihat"),
                          _buildVerticalLine(),
                          _buildStatItem("64", "Chat Wa"),
                          _buildVerticalLine(),
                          _buildStatItem("4.8", "Rating"),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- GAMBAR TOKO ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: (data['fotoToko'] != null && data['fotoToko'] != '')
                            ? Image.network(data['fotoToko'], fit: BoxFit.cover)
                            : const Icon(Icons.store, size: 50, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- INFO DETAIL ---
                    _buildInfoRow(Icons.storefront, "Kategori", data['kategori'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on_outlined, "Alamat", data['alamat'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.description_outlined, "Deskripsi", data['deskripsi'] ?? '-'),

                    const SizedBox(height: 30),

                    // --- TOMBOL KELOLA PRODUK ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // INI MENUJU KE HALAMAN LIST PRODUK (Gambar Kanan)
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (c) => const KelolaTokoPage())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                        label: const Text("Kelola Produk", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVerticalLine() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade800, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade900)),
            ],
          ),
        ),
      ],
    );
  }
}