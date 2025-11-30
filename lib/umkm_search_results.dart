import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_toko_page.dart';

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
  late Future<List<DocumentSnapshot>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = _performSearch();
  }

  Future<List<DocumentSnapshot>> _performSearch() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Query sellers berdasarkan nama toko atau deskripsi yang mengandung search query
      final query = firestore.collection('sellers');
      final snapshot = await query.get();

      List<DocumentSnapshot> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final namaToko = (data['namaToko'] as String?)?.toLowerCase() ?? '';
        final deskripsi = (data['deskripsi'] as String?)?.toLowerCase() ?? '';
        final kategori = (data['kategori'] as String?)?.toLowerCase() ?? '';
        final searchLower = widget.searchQuery.toLowerCase();

        // Filter by search query
        final matchesSearch =
            namaToko.contains(searchLower) || deskripsi.contains(searchLower);

        // Filter by kategori if specified
        final matchesFilter =
            widget.selectedFilter == null ||
            widget.selectedFilter == 'Semua' ||
            kategori == widget.selectedFilter?.toLowerCase();

        if (matchesSearch && matchesFilter) {
          results.add(doc);
        }
      }

      return results;
    } catch (e) {
      debugPrint('Search error: $e');
      rethrow;
    }
  }

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
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _searchResults = _performSearch();
                    }),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  if (widget.selectedFilter != null &&
                      widget.selectedFilter != 'Semua')
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

          final results = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return _buildUmkmCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildUmkmCard(DocumentSnapshot sellerDoc) {
    final data = sellerDoc.data() as Map<String, dynamic>;
    final item = {
      'namaToko': data['namaToko'] ?? 'Toko Tanpa Nama',
      'deskripsi': data['deskripsi'] ?? '',
      'kategori': data['kategori'] ?? 'Umum',
      'foto': data['foto'] ?? '',
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
