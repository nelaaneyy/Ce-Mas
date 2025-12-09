import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cemas/features/user/pages/detail_toko_page.dart';

class UmkmSearchResults extends StatefulWidget {
  final String searchQuery;
  final String? selectedFilter; // Optional filter (kategori)

  const UmkmSearchResults({
    super.key,
    required this.searchQuery,
    this.selectedFilter,
  });

  @override
  State<UmkmSearchResults> createState() => _UmkmSearchResultsState();
}

class _UmkmSearchResultsState extends State<UmkmSearchResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'Hasil Pencarian: "${widget.searchQuery}"',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return _buildEmptyState();
          }

          // Lakukan filtering di client-side agar realtime
          // (Firestore tidak support partial text search native secara realtime dengan mudah)
          final allDocs = snapshot.data!.docs;
          final filteredDocs = allDocs.where((doc) {
             final data = doc.data() as Map<String, dynamic>;
             final namaToko = (data['namaToko'] as String?)?.toLowerCase() ?? '';
             final deskripsi = (data['deskripsi'] as String?)?.toLowerCase() ?? '';
             final kategori = (data['kategori'] as String?)?.toLowerCase() ?? '';
             final searchLower = widget.searchQuery.toLowerCase();

             // Filter by search query
             final matchesSearch = namaToko.contains(searchLower) || deskripsi.contains(searchLower);

             // Filter by kategori if specified
             final matchesFilter = widget.selectedFilter == null ||
                widget.selectedFilter == 'Semua' ||
                kategori == widget.selectedFilter?.toLowerCase();
             
             return matchesSearch && matchesFilter;
          }).toList();

          if (filteredDocs.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final item = filteredDocs[index];
              return _buildUmkmCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil untuk "${widget.searchQuery}"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (widget.selectedFilter != null && widget.selectedFilter != 'Semua')
            Text(
              'Kategori: ${widget.selectedFilter}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildUmkmCard(DocumentSnapshot sellerDoc) {
    final data = sellerDoc.data() as Map<String, dynamic>;
    final item = {
      'namaToko': data['namaToko'] ?? 'Toko Tanpa Nama',
      'deskripsi': data['deskripsi'] ?? '',
      'kategori': data['kategori'] ?? 'Umum',
      'foto': data['fotoUmkm'] ?? data['fotoToko'] ?? '',
      'alamat': data['alamat'] ?? '',
      'noWhatsapp': data['noWhatsapp'] ?? '',
    };

    return GestureDetector(
      onTap: () {
        // Navigate to detail UMKM page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTokoPage(sellerData: sellerDoc),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade200,
                ),
                child:
                    item['foto'] != null && item['foto'].toString().isNotEmpty
                    ? Image.network(
                        item['foto'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.store, size: 40, color: Colors.grey),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['namaToko'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['kategori'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['deskripsi'],
                    style: const TextStyle(fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
