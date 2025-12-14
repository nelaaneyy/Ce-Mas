import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cemas/core/theme/app_theme.dart';
import 'package:cemas/features/user/widgets/umkm_list_tile.dart';
import 'package:cemas/features/user/pages/umkm_search_page.dart';

class UmkmPage extends StatefulWidget {
  const UmkmPage({super.key});

  @override
  State<UmkmPage> createState() => _UmkmPageState();
}

class _UmkmPageState extends State<UmkmPage> {
  // State untuk filter, sama seperti di BerandaPage
  final List<String> _filters = [
    'Semua',
    'Kelontong',
    'Kuliner',
    'Jasa',
    'Transportasi',
  ];
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('UMKM'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UmkmSearchPage(),
                  ),
                );
              },
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Cari UMKM/Produk/Jasa',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: AppTheme.backgroundWhite,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSM),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.textSecondary, size: 30),
            onPressed: () {},
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
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXS),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: _selectedFilter == _filters[index],
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = _filters[index];
                });
              },
              backgroundColor: AppTheme.backgroundWhite,
              selectedColor: AppTheme.primaryBlueLight.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                side: const BorderSide(color: AppTheme.borderColor),
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
