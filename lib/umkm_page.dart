import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'umkm_list_tile.dart'; // Import widget baru kita

class UmkmPage extends StatefulWidget {
  const UmkmPage({super.key});

  @override
  State<UmkmPage> createState() => _UmkmPageState();
}

class _UmkmPageState extends State<UmkmPage> {
  // State untuk filter, sama seperti di BerandaPage
  final List<String> _filters = ['Semua', 'Kelontong', 'Kuliner', 'Jasa', 'Transportasi'];
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // 1. AppBar Sederhana (sesuai desain)
      appBar: AppBar(
        title: const Text(
          'UMKM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
        backgroundColor: Colors.blue.shade800, // Latar belakang putih
        elevation: 0,
        automaticallyImplyLeading: false, // Sembunyikan tombol 'back'
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 2. Search Bar & Filter Button
          _buildSearchBar(),
          
          // 3. Filter Chips
          _buildFilterChips(),
          
          // 4. Daftar UMKM (StreamBuilder)
          _buildUmkmList(),
        ],
      ),
    );
  }

  // Widget untuk Search Bar
  Widget _buildSearchBar() {
    return Padding(
      // Beri background putih agar kontras dengan body
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari UMKM/Produk/Jasa',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                // Border standar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                // Border saat tidak di-klik
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                // Border saat di-klik
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade800),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tombol Filter
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[800], size: 30),
            onPressed: () {
              // TODO: Tampilkan modal filter
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk Filter Chips (sama seperti di BerandaPage)
  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: _selectedFilter == _filters[index],
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = _filters[index];
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Widget untuk Daftar UMKM
  Widget _buildUmkmList() {
    // Logika query-nya sama persis dengan BerandaPage
    Query query = FirebaseFirestore.instance.collection('sellers');
    if (_selectedFilter != 'Semua') {
      // Pastikan field 'kategori' ada di dokumen 'sellers' kamu
      query = query.where('kategori', isEqualTo: _selectedFilter);
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada UMKM ditemukan.'));
          }

          var sellerDocs = snapshot.data!.docs;

          // Bedanya di sini: Kita pakai ListView.builder
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10.0),
            itemCount: sellerDocs.length,
            itemBuilder: (context, index) {
              // dan kita panggil widget baru kita (UmkmListTile)
              return UmkmListTile(sellerData: sellerDocs[index]);
            },
          );
        },
      ),
    );
  }
}